class ReplaceListingCategoryWithCategoryRef < ActiveRecord::Migration[7.2]
  def change
    add_reference :listings, :category, foreign_key: true, null: true
    # Nếu muốn bắt buộc chọn category ngay lập tức:
    # change_column_null :listings, :category_id, false
  end
end
