class Spree::Gateway::Khalti < Spree::Gateway
  attr_accessor :server, :test_mode

  preference :server,:string, default: 'test'
  preference :test_mode, :boolean, default: true
  preference :test_public_key, :string
  preference :test_secret_key, :string
  preference :live_public_key, :string
  preference :live_secret_key, :string

  def provider_class
    Spree::Gateway::Khalti
  end
  def payment_source_class
    Spree::PaymentMethod
  end

  def method_type
    'khalti'
  end

  def purchase(amount, transaction_details, options = {})
    # Have to write the code to verify the transaction here
    # and send the success response to the frontend here
    ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
  end
end
