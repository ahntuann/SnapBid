class AddHomeFieldsToListings < ActiveRecord::Migration[7.2]
  def change
    add_column :listings, :start_price, :decimal
    add_column :listings, :published_at, :datetime
  end
end
