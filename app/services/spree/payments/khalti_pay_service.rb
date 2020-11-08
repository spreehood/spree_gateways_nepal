module Spree
  module Payments
    class KhaltiPayService
      def initialize(payment_method_preference:, token:, amount:)
        @payment_method_preference = payment_method_preference
        @token = token
        @amount = amount
      end

      def call
        https = Net::HTTP.new(api_url.host, api_url.port)
        https.use_ssl = true
        request = Net::HTTP::Post.new(
          api_url.request_uri,
          { Authorization: "Key #{authorization}"}
        )
        request.set_form_data('token' => @token, 'amount' => @amount.to_d)
        response = https.request(request)
        parsed_response(response.body)
      end

      private

      attr_reader :authorization, :url

      def authorization
        @authorization ||= @payment_method_preference[:test_mode] ?
          @payment_method_preference[:test_secret_key] :
          @payment_method_preference[:live_secret_key]
      end

      def api_url
        @url ||= URI.parse('https://khalti.com/api/v2/payment/verify/')
      end

      def parsed_response(response)
        if response.code == '200'
          {
            status: true
          }
        else
          {
            status: false,
            errors: JSON.parse(response)['detail']
          }
        end
      end
    end
  end
end
