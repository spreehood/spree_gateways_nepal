class Spree::Gateway::Khalti < Spree::Gateway
  attr_accessor :server, :test_mode


  preference :server,:string, default: 'test'
  preference :test_mode, :boolean, default: true

  def provider_class
    Spree::Gateway::Khalti
  end
  def payment_source_class
    Spree::CreditCard
  end

  def method_type
    'khalti'
  end

  def purchase(amount, transaction_details, options = {})
    binding.pry
    ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
  end
end
