class CreateBids < ActiveRecord::Migration[7.2]
  def change
    create_table :bids do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 0, null: false

      t.timestamps
    end
  end
end
