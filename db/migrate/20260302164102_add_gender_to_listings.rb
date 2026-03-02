class AddGenderToListings < ActiveRecord::Migration[7.2]
  def change
    add_column :listings, :gender, :string
  end
end
