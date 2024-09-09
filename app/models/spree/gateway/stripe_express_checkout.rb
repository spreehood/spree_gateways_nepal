require 'spree_gateway'

module Spree
  class Gateway::StripeExpressCheckout < Gateway

    def auto_capture?
      true
    end

    def provider_class
      Spree::Gateway::StripeExpressCheckout
    end

    def payment_source_class
      Spree::StripeExpressCheckoutSource
    end

    def purchase(amount, source, options = {})
      Class.new do
        def success?; true; end
        def authorization; nil; end
      end.new
    end

    def method_type
      'stripe_express_checkout'
    end
  end
end
