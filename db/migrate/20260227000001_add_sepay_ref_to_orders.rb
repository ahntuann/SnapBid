class AddSepayRefToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :sepay_ref, :string
    add_index  :orders, :sepay_ref, unique: true
    add_column :orders, :sepay_paid_at, :datetime
  end
end
