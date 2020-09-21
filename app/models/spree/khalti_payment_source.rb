module Spree
  class Spree::KhaltiPaymentSource < Spree::Base
    belongs_to :payment_method
    has_many :payments, as: :source

    def actions
      []
    end

    def transaction_id
      payment_id
    end

    def method_type
      'khalti_payment_source'
    end

    def name
      'Khalti Wallet'
    end

  end
end