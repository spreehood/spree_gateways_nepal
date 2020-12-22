module Spree
  class EsewaController < StoreController
    skip_before_action :verify_authenticity_token
    # before_action :payment_method, only: [:payment]

    def payment
      # Call service to call the esewa payment

      # parameters = {
      #   "amt"=> params[:amt].to_f,
      #   "scd"=> 'EPAYTEST',
      #   "rid"=> params[:refId],
      #   "pid"=> params[:oid]
      # }

      # uri = URI.parse("https://uat.esewa.com.np/epay/transrec")

      # https = Net::HTTP.new(uri.host, uri.port)
      # https.use_ssl = true
      # request = Net::HTTP::Post.new(uri.request_uri)
      # request.set_form_data(parameters)
      # response = https.request(request)

      # response_data = Hash.from_xml(response.body)

      # if response_data["response"]["response_code"].strip().eql?("Success")
      # else
      # end

      order = current_order || raise(ActiveRecord::RecordNotFound)
      payment_method = Spree::Gateway::Esewa.find_by(type: "Spree::Gateway::Esewa")
      current_payment = create_payment(payment_method)
      current_payment.pend!
      current_payment.update(response_code: params[:refId])

      current_payment.source.update({
        pid: params[:oid],
        rid: params[:refId],
        payment_method_id: payment_method.id,
        user_id: current_order.user.id
      })

      current_payment.process!
      unless current_order.next
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to checkout_state_path(current_order.state) and return
      end

      redirect_to completion_route(order)
      # From here call the esewa page with the data to be sent
    end

    private

    def payment_method
      @payment_method = Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def completion_route(order)
      order_path(order)
    end

    def create_payment(payment_method)
      payment = current_order.payments.build(
        payment_method_id: payment_method.id,
        amount: current_order.total,
        state: 'checkout',
        source: Spree::EsewaPaymentSource.create
      )

      unless payment.save!
        flash[:error] = payment.errors.full_messages.join("\n")
        redirect_to checkout_state_path(current_order.state) and return
      end

      payment
    end

  end
end
