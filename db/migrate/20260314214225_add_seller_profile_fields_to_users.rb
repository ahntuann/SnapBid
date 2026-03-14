class AddSellerProfileFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :shop_name, :string
    add_column :users, :bio, :text
    add_column :users, :location, :string
  end
end
