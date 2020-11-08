class Spree::Gateway::Khalti < Spree::Gateway

  preference :test_mode, :boolean, default: true
  preference :test_public_key, :string
  preference :test_secret_key, :string
  preference :live_public_key, :string
  preference :live_secret_key, :string

  def auto_capture?
    true
  end

  def provider_class
    # Spree::Gateway::Khalti
    self.class
  end

  def payment_source_class
    # Spree::KhaltiPaymentSource
  end

  def purchase(amount, source, options = {})
    # Class.new do
    #   def success?; true; end
    #   def authorization; nil; end
    # end.new

    khalti_service_response = Spree::Payments::KhaltiPayService.new(
      payment_method_preference: options[:preference],
      token: options[:token],
      amount: amount
    ).call

    ActiveMerchant::Billing::Response.new(
      khalti_service_response['status'],
      khalti_service_response['message']
    )
  end

  def method_type
    'khalti'
  end

  def paisa_rate
    100
  end
end
