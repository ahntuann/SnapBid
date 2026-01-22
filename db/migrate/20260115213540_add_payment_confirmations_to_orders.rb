class AddPaymentConfirmationsToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :buyer_marked_paid_at, :datetime
    add_column :orders, :admin_confirmed_paid_at, :datetime
  end
end
