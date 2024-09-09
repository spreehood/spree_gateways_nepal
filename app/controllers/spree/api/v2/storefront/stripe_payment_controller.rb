# frozen_string_literal: true

module Spree
  module Api
    module V2
      module Storefront
        class StripePaymentController < ::Spree::Api::V2::BaseController
          def create
            order = Spree::Order.find(params[:order_id])

            # Frontend issues multiple requests for payment creation
            # This check is to ensure that only one payment is created
            # Remove later after the issue in the frontend is fixed
            if order.payments.count > 0
              return render json: { error: 'Order already has a payment' }, status: :unprocessable_entity
              # return
            end
            
            payment_method = Spree::PaymentMethod.find_by(type: 'Spree::Gateway::StripeExpressCheckout')

            payment = order.payments.build(
              payment_method_id: payment_method.id,
              response_code: params[:payment_intent_id],
              amount: order.total,
              source: create_source(payment_method),
              state: 'checkout'
            )

            begin
              if payment.save
                if payment.state == 'checkout'
                  payment.process!
                end

                render json: { message: 'Payment created successfully' }, status: :ok
              else
                render json: { error: 'Payment could not be completed' }, status: :unprocessable_entity
              end
            rescue StateMachines::InvalidTransition => e
              render json: { error: e.message }, status: :unprocessable_entity
            rescue StandardError => e
              render json: { error: e.message }, status: :unprocessable_entity
            end
          end

          private

          def create_source(payment_method)
            Spree::StripeExpressCheckoutSource.create!(
              payment_intent_id: params[:payment_intent_id],
              payment_intent_secret: params[:payment_intent_secret],
              payment_method_id: payment_method.id
            )
          end
        end
      end
    end
  end
end
