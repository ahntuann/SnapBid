class ReferenceItem < ApplicationRecord
  has_many_attached :images
  has_many :listings
  validates :name, presence: true
end