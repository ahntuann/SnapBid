class AddReferenceItemIdToListings < ActiveRecord::Migration[7.2]
  def change
    add_reference :listings, :reference_item, null: true, foreign_key: true
  end
end
