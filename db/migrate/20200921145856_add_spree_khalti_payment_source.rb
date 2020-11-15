class AddSpreeKhaltiPaymentSource < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_khalti_payment_sources do |t|
      t.string :khalti_payment_token_id
      t.string :khalti_payment_type_id
      t.string :khalti_payment_type_name
      t.string :payment_state_id
      t.string :payment_state_name
      t.string :payment_state_template
      t.float :amount
      t.float :fee_amount
      t.boolean :refunded
      t.datetime :created_on
      t.string :ebanker
      t.string :khalti_user_id
      t.string :khalti_user_name
      t.string :khalti_user_email
      t.string :khalti_user_mobile
      t.string :khalti_merchant_id
      t.string :khalti_merchant_name
      t.string :khalti_merchant_email
      t.string :khalti_merchant_mobile
      t.integer :payment_method_id
      t.integer :user_id
      t.timestamps
    end
  end
end
