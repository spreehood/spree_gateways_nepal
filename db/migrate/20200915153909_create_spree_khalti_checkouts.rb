class CreateSpreeKhaltiCheckouts < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_khalti_checkouts do |t|
      t.string :token
      t.string :state
    end
  end
end
