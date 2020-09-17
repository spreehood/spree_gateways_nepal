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


  end
end