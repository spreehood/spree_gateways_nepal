module Spree
  class EsewaController < StoreController
    skip_before_action :verify_authenticity_token

    def payment
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
