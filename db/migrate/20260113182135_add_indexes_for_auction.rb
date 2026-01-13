class AddIndexesForAuction < ActiveRecord::Migration[7.2]
  def change
    add_index :bids, [:listing_id, :amount] unless index_exists?(:bids, [:listing_id, :amount])

    # orders.listing_id đã có index sẵn do t.references thường tự tạo
    # Nếu muốn unique thì chỉ add nếu chưa tồn tại unique index
    unless index_exists?(:orders, :listing_id, unique: true)
      # Nếu đang có index thường, bỏ nó trước rồi tạo unique
      if index_exists?(:orders, :listing_id)
        remove_index :orders, :listing_id
      end
      add_index :orders, :listing_id, unique: true
    end

    add_index :listings, :published_at unless index_exists?(:listings, :published_at)
    add_index :listings, :status unless index_exists?(:listings, :status)
  end
end
