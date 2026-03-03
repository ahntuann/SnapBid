class AddIsSellerToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :is_seller, :boolean, default: false, null: false
  end
end
