class CreateCoinDeposits < ActiveRecord::Migration[7.2]
  def change
    create_table :coin_deposits do |t|
      t.references :user, null: false, foreign_key: true
      t.integer    :amount_vnd,       null: false, default: 0
      t.integer    :coins_credited,   null: false, default: 0
      t.string     :deposit_ref,      null: false  # e.g. SBC42
      t.string     :sepay_transaction_id
      t.datetime   :credited_at

      t.timestamps
    end

    add_index :coin_deposits, :deposit_ref
    add_index :coin_deposits, :sepay_transaction_id, unique: true
  end
end
