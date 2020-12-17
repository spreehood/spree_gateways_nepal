module Spree
  class EsewaController < StoreController
    skip_before_action :verify_authenticity_token
    before_action :payment_method, only: [:payment]

    def payment
      # Call service to call the esewa payment
      binding.pry
      @order = current_order
      current_referrer_url = request.referrer
      order_complete_url = order_url(current_order)

      request_body = {
        amt: @order.item_total,
        pdc: @order.shipment_total,
        psc: 0, # TODO: Lookup for service charge field
        txAmt: @order.additional_tax_total,
        tAmt: @order.total,
        pid: @order.number,
        scd: 'EPAYTEST',
        su: current_referrer_url,
        fu: current_referrer_url
      }.to_json

      @url ||= payment_method[:preferences][:test_mode] ?
          payment_method[:preferences][:sandbox_url] :
          payment_method[:preferences][:production_url]

      response = connection.post(@url, request_body)
      binding.pry
      # From here call the esewa page with the data to be sent
    end

    private

    def payment_method
      @payment_method = Spree::PaymentMethod.find(params[:payment_method_id])
    end

  end
end
