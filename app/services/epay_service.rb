module Spree
    class EpayService
      def initialize(order, payment_method)
        @order = order
        @payment_method = payment_method
      end

      def payment
        response = connection.post(api_url, request_body)
        response.body
      end

      private

      # Setting to true will log requests and response to $stdout,
      # should always be set to false when commiting code
      DEBUG_MODE = false

      attr_reader :order, :payment_method, :url

      def api_url
        @url ||= payment_method[:preferences][:test_mode] ?
          payment_method[:preferences][:sandbox_url] :
          payment_method[:preferences][:production_url]
      end

      def connection
        Faraday.new do |faraday|
          faraday.response :logger if DEBUG_MODE
          faraday.adapter Faraday.default_adapter
          faraday.headers['Content-Type'] = 'application/json'
        end
      end

      # From epay documentation: https://developer.esewa.com.np/#/epay
      # amt:	Amount of product or item or ticket etc
      # txAmt:	Tax amount on product or item or ticket etc
      # psc:	Service charge by merchant on product or item or ticket etc
      # pdc:	Delivery charge by merchant on product or item or ticket etc
      # tAmt:	Total payment amount including tax, service and deliver charge. [i.e tAmt = amt + txAmt + psc + tAmt]
      # pid:	A unique ID of product or item or ticket etc
      # scd:	Merchant code provided by eSewa
      # su:	Success URL: a redirect URL of merchant application where customer will be redirected after SUCCESSFUL transaction
      # fu:	Failure URL: a redirect URL of merchant application where customer will be redirected after FAILURE or PENDING transaction
      def request_body
        {
          amt: @order.item_total,
          pdc: @order.shipment_total,
          psc: 0, # TODO: Lookup for service charge field
          txAmt: @order.additional_tax_total,
          tAmt: @order.total,
          pid: @order.number,
          scd: @payment_method.preferences[:merchant_code],
          su: @payment_method.preferences[:successful_callback_url],
          fu: @payment_method.preferences[:failure_callback_url]
        }.to_json
      end
    end
end
