require 'uri'
require 'net/http'
module Spree
  class KhaltiController < StoreController
    skip_before_action :verify_authenticity_token

    def payment
      headers = {
        Authorization: 'Key test_secret_key_3bab07ad22d741d8b1e9cae0e7040a33'
      }
      uri = URI.parse('https://khalti.com/api/v2/payment/verify/')
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.set_form_data('token' => params[:token], 'amount' => params[:amount].to_f)
      response = https.request(request)

      render json: {message: 'Successfully transfered fund from Khalti'}, status: :ok
    end

    def khalti_payment_config
      config = {
        publicKey: "",
        productIdentity: current_order.number,
        productName: current_order.products.first.name,
        productUrl: "http://hello.com",
        paymnetPreference: ["MOBILE_BANKING", "KHALTI", "EBANKING","CONNECT_IPS","SCT"],
        checkoutAmount: (current_order.total) * 100 #Converting to Paisa
      }
      respond_to do |format|
        format.html {  }
        format.json {render json: config, status: :ok}
      end
      # render json: config, status: :ok
    end

  end
end