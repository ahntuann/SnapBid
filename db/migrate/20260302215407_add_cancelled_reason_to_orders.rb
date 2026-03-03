class AddCancelledReasonToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :cancelled_reason, :string
  end
end
