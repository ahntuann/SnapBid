class Listing < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :ai_verifications, dependent: :destroy

  enum :status, {
    draft: 0,
    submitted_for_ai: 1,
    verified: 2,
    rejected: 3,
    manual_review: 4,
    published: 5
  }

  scope :published, -> { where.not(published_at: nil).order(published_at: :desc) }

  after_initialize do
    self.status ||= :draft if new_record?
  end

  validates :title, presence: true
  validates :seller_note, presence: true

  def status_text
    I18n.t("enums.listing.status.#{status}")
  end
end
