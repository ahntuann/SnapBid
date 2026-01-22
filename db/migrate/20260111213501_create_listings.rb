class CreateListings < ActiveRecord::Migration[7.2]
  def change
    create_table :listings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :category
      t.string :condition
      t.text :seller_note
      t.integer :status
      t.text :ai_note

      t.timestamps
    end
  end
end
