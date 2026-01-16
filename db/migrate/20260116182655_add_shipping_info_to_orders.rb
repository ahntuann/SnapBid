class AddShippingInfoToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :recipient_name, :string
    add_column :orders, :recipient_phone, :string
    add_column :orders, :shipping_address, :text
  end
end
