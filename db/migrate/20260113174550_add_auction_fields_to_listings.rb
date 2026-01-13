class AddAuctionFieldsToListings < ActiveRecord::Migration[7.2]
  def change
    add_column :listings, :reserve_price, :decimal
    add_column :listings, :bid_increment, :decimal
    add_column :listings, :auction_ends_at, :datetime
  end
end
