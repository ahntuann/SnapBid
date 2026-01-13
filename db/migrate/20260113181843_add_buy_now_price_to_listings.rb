class AddBuyNowPriceToListings < ActiveRecord::Migration[7.2]
  def change
    add_column :listings, :buy_now_price, :decimal, precision: 12, scale: 0
  end
end
