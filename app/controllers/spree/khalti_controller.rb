require 'uri'
require 'net/http'
module Spree
  class KhaltiController < StoreController
    skip_before_action :verify_authenticity_token

    def payment
      @payment_method = PaymentMethod.find(params[:payment_method_id])

      headers = {
        Authorization: "Key #{@payment_method.preferences[:test_secret_key]}"
      }
      uri = URI.parse('https://khalti.com/api/v2/payment/verify/')
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.set_form_data('token' => params[:payload][:token], 'amount' => params[:payload][:amount].to_f)
      response = https.request(request)
      render json: {message: response.message, code: response.code}
    end

    # To be used when configurations need to be fetched from the UI
    def khalti_payment_config
      @payment_method = PaymentMethod.find(params[:payment_method_id])

      config = {
        publicKey: @payment_method.preferences[:test_public_key],
        productIdentity: current_order.number,
        productName: current_order.number,
        productUrl: "#{current_store.url}/orders/#{current_order.number}",
        paymnetPreference: ["MOBILE_BANKING", "KHALTI", "EBANKING","CONNECT_IPS","SCT"],
        checkoutAmount: (current_order.total) * 100 #Converting to Pais
      }

      render json: {config: config}, status: :ok
    end
  end
end