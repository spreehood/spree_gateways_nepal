module Spree
  class KhaltiController < StoreController
    skip_before_action :verify_authenticity_token

    def payment
      payment_method = PaymentMethod.find(params[:payment_method_id])

      order = current_order || raise(ActiveRecord::RecordNotFound)

      current_payment = create_payment(payment_method)
      current_payment.pend!

      begin
        # API call to khalti
        headers = {
          Authorization: "Key #{payment_method.preferences[:test_mode] ? payment_method.preferences[:test_secret_key] :  payment_method.preferences[:live_secret_key] }"
        }
        uri = URI.parse('https://khalti.com/api/v2/payment/verify/')
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.set_form_data('token' => params[:payload][:token], 'amount' => params[:payload][:amount].to_f)
        response = https.request(request)

        if response_code.eql?(200)
          responseJSON = JSON.parse(response.body)

          # Update the payment source with the response then complete
          current_payment.update!(response_code: responseJSON['idx'])
          current_payment.source.update!(khalti_response_attributes(responseJSON).merge({payment_method_id: payment_method.id, user_id: current_order.user.id}))
          current_payment.process!

          unless current_order.next
            flash[:error] = @order.errors.full_messages.join("\n")
            redirect_to checkout_state_path(current_order.state) and return
          end

          redirect_to completion_route(order)
        else
          current_payment.invalid!
          flash[:error] = Spree.t('flash.generic_error', scope: 'khalti', reasons: 'Server verification with khalti failed')

          redirect_to checkout_state_path(:payment)
        end

      rescue SocketError
        current_payment.invalid!
        flash[:error] = Spree.t('flash.connection_failed', scope: 'khalti')

        redirect_to checkout_state_path(:payment)
      end

    end

    # To be used when configurations need to be fetched from the UI
    def khalti_payment_config
      @payment_method = PaymentMethod.find(params[:payment_method_id])
      config = {
        publicKey: @payment_method.preferences[:test_public_key],
        productIdentity: current_order.number,
        productName: current_order.number,
        productUrl: "#{current_store.url}/orders/#{current_order.number}",
        paymentPreference: ["MOBILE_BANKING", "KHALTI", "EBANKING","CONNECT_IPS","SCT"],
        checkoutAmount: (current_order.total) * paisa_rate #Converting to Pais
      }

      render json: {config: config}, status: :ok
    end

    def provider
      payment_method.provider
    end

    def completion_route(order)
      order_path(order)
    end

    def create_payment(payment_method)
      payment = current_order.payments.build(
        payment_method_id: payment_method.id,
        amount: current_order.total,
        state: 'checkout',
        source: Spree::KhaltiPaymentSource.create
      )

      unless payment.save!
        flash[:error] = payment.errors.full_messages.join("\n")
        redirect_to checkout_state_path(current_order.state) and return
      end

      payment
    end

    def khalti_response_attributes(responseJSON)
      update_attributes = {
        khalti_payment_token_id: responseJSON['idx'],
        khalti_payment_type_id: responseJSON['type']['idx'],
        khalti_payment_type_name: responseJSON['type']['name'],
        payment_state_id: responseJSON['state']['idx'],
        payment_state_name: responseJSON['state']['name'],
        payment_state_template: responseJSON['state']['template'],
        amount: responseJSON['amount'],
        fee_amount: responseJSON['fee_amount'],
        refunded: responseJSON['refunded'],
        created_on: responseJSON['created_on'],
        ebanker: responseJSON['ebanker'],
        khalti_user_id: responseJSON['user']['idx'],
        khalti_user_name: responseJSON['user']['name'],
        khalti_user_email: responseJSON['user']['email'],
        khalti_user_mobile: responseJSON['user']['mobile'],
        khalti_merchant_id: responseJSON['merchant']['idx'],
        khalti_merchant_name: responseJSON['merchant']['name'],
        khalti_merchant_mobile: responseJSON['merchant']['mobile'],
        khalti_merchant_email: responseJSON['merchant']['email']
      }
    end

  end

end
