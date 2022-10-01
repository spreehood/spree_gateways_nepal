module Spree
  class Spree::EsewaPaymentSource < Spree::Base
    belongs_to :payment_method

    has_many :payments, as: :source

    def actions
      []
    end

    def transaction_id
      payment_id
    end

    def method_type
      'esewa_payment_source'
    end

    def name
      'Esewa Epay'
    end
  end
end