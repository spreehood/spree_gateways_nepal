class Spree::Gateway::Khalti < Spree::Gateway
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
    ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
  end
end
