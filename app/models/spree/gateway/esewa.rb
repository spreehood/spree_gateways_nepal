module Spree
  class Gateway::Esewa < Gateway
    preference :mode, :string
    preference :sandbox_url, :string
    preference :production_url, :string
    preference :scd, :string, default: 'epay_payment'
    preference :username, :string
    preference :password, :string

    def provider_class
      ActiveMerchant::Billing::EsewaGateway
    end
  end
end
