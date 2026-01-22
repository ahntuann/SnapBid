class AddTotalToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :total, :decimal
  end
end
