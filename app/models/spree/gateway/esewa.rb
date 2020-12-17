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

    def purchase
      # TODO: Trigger esewa payment service
    end
  end
