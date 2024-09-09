class CreateSpreeStripeExpressCheckoutSource < ActiveRecord::Migration[7.1]
  def change
    create_table :spree_stripe_express_checkout_sources do |t|
      t.string :payment_intent_id
      t.string :payment_intent_secret
      t.integer :payment_method_id
      t.timestamps
    end
  end
end
