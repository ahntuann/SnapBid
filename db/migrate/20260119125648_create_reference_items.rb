class CreateReferenceItems < ActiveRecord::Migration[7.2]
  def change
    create_table :reference_items do |t|
      t.string :name
      t.string :brand
      t.text :description

      t.timestamps
    end
  end
end
