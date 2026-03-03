class CreateWithdrawalRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :withdrawal_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false
      t.string :bank_name, null: false
      t.string :account_number, null: false
      t.string :account_name, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
