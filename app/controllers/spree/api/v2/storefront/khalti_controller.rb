require 'net/http'
require 'uri'

module Spree
  module Api
    module V2
      module Storefront
        class KhaltiController < Spree::Api::V2::ResourceController
          before_action :require_spree_current_user
          before_action :find_order
          
          def payment_initiate
            payment_method = PaymentMethod.find(params[:payment_method_id])

            order = @order || raise(ActiveRecord::RecordNotFound)

            begin
              headers = {
                'Authorization' => "Key #{payment_method.preferences[:test_mode] ? payment_method.preferences[:test_secret_key] : payment_method.preferences[:live_secret_key]}",
                'Content-Type' => 'application/json'
              }

              uri = if !payment_method.preferences[:test_mode]
                      URI.parse('https://khalti.com/api/v2/epayment/initiate/')
                    else
                      URI.parse('https://a.khalti.com/api/v2/epayment/initiate/')
                    end

              https = Net::HTTP.new(uri.host, uri.port)
              https.use_ssl = true
              request = Net::HTTP::Post.new(uri.request_uri, headers)

              # Prepare the payload
              payload = {
                'amount' => params[:amount].to_f,
                'purchase_order_id' => params[:purchase_order_id],
                'purchase_order_name' => params[:purchase_order_name],
                'website_url' => params[:website_url],
                'return_url' => params[:return_url]
              }

              request.body = payload.to_json

              response = https.request(request)

              if response.code.to_i == 200
                current_payment = create_payment(payment_method)
                current_payment.pend!
                response_json = JSON.parse(response.body)
                render json: response_json, status: :ok
              else
                response_json = JSON.parse(response.body) rescue {}
                render json: response_json, status: :unprocessable_entity
              end

            rescue JSON::ParserError
              render json: { error: 'Error parsing response' }, status: :unprocessable_entity
            rescue SocketError
              render json: { error: 'Network connection error' }, status: :service_unavailable
            rescue StandardError => e
              render json: { error: e.message }, status: :internal_server_error
            end
          end

          def update
            payment_method = PaymentMethod.find(params[:payment_method_id])

            current_payment = @order.payments.last

            begin
              headers = {
                'Authorization' => "Key #{payment_method.preferences[:test_mode] ? payment_method.preferences[:test_secret_key] : payment_method.preferences[:live_secret_key]}",
                'Content-Type' => 'application/json'
              }

              uri = if !payment_method.preferences[:test_mode]
                      URI.parse('https://khalti.com/api/v2/epayment/lookup/')
                    else
                      URI.parse('https://a.khalti.com/api/v2/epayment/lookup/')
                    end

              https = Net::HTTP.new(uri.host, uri.port)
              https.use_ssl = true
              request = Net::HTTP::Post.new(uri.request_uri, headers)

              # Prepare the payload
              payload = {
                'pidx' => params[:pidx]
              }

              request.body = payload.to_json
              response = https.request(request)

              if response.code.to_i == 200
                response_json = JSON.parse(response.body)

                current_payment.update!(response_code: response_json['pidx'])
                current_payment.source.update!(
                  khalti_response_attributes(response_json).merge({
                    payment_method_id: payment_method.id,
                    user_id: @order.user.id
                  })
                )
                current_payment.process!

                render json: response_json, status: :ok
              else
                response_json = JSON.parse(response.body) rescue {}
                render json: response_json, status: :unprocessable_entity
              end

            rescue JSON::ParserError
              render json: { error: 'Error parsing response' }, status: :unprocessable_entity
            rescue SocketError
              render json: { error: 'Network connection error' }, status: :service_unavailable
            rescue StandardError => e
              render json: { error: e.message }, status: :internal_server_error
            end
          end

          private

          def find_order
            @order ||= Spree::Order.find(params[:purchase_order_id])
          end

          def khalti_response_attributes(response_json)
            {
              pidx: response_json['pidx'],
              total_amount: response_json['total_amount'],
              status: response_json['status'],
              transaction_id: response_json['transaction_id'],
              fee: response_json['fee'],
              refunded: response_json['refunded']
            }
          end

          def create_payment(payment_method)
            payment = @order.payments.build(
              payment_method_id: payment_method.id,
              amount: @order.total,
              state: 'checkout',
              source: Spree::KhaltiPaymentSource.create
            )

            unless payment.save!
              render json: { error: payment.errors.full_messages.join("\n") }, status: :unprocessable_entity
            end

            payment
          end
        end
      end
    end
  end
end
