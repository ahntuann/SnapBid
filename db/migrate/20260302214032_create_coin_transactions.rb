class CreateCoinTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :coin_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false
      t.integer :balance_after, null: false
      t.integer :transaction_type, null: false
      t.string :description
      t.references :subject, polymorphic: true, null: true

      t.timestamps
    end
  end
end
