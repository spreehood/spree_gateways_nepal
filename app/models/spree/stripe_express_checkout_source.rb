# frozen_string_literal: true

module Spree
  class StripeExpressCheckoutSource < Spree::Base
    belongs_to :payment_method

    has_many :payments, as: :source

    def transaction_id
      payment_intent_id
    end

    def actions
      []
    end

    def method_type
      'stripe_express_checkout_source'
    end

    def name
      'Stripe Express Checkout'
    end
  end
end
