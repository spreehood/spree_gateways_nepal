  class Spree::Gateway::Esewa < Spree::Gateway
    preference :sandbox_url, :string
    preference :production_url, :string
    preference :merchant_code, :string, default: 'epay_payment'
    preference :successful_callback_url, :string
    preference :failure_callback_url, :string
    preference :fraud_check_url, :string
    preference :server, :select, default: -> { { values: [:sandbox, :production] } }

    def provider_class
      Esewa
    end

    def auto_capture?
      true
    end

    def method_type
      'esewa'
    end

    def payment_source_class
      Spree::SpreePaymentSource
    end

    def purchase(amount, source, options={})
      Class.new do
        def success?; true; end
        def authorization; nil; end
      end.new
    end
  end
