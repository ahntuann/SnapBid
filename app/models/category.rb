# app/models/category.rb
class Category < ApplicationRecord
  has_many :listings, dependent: :restrict_with_exception
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :ordered, -> {
    order(
      Arel.sql("CASE WHEN lower(name) IN ('khác','khac') THEN 1 ELSE 0 END ASC"),
      Arel.sql("lower(name) ASC")
    )
  }
end
