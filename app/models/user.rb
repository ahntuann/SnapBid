class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  enum :role, { user: 0, cs: 1, admin: 2 }

  has_many :otps, dependent: :destroy
  has_many :listings
  has_many :orders, foreign_key: :buyer_id, dependent: :nullify
  has_many :bids, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy

  has_one_attached :avatar

  after_initialize do
    self.role ||= :user if new_record?
  end

  def email_verified?
    email_verified_at.present?
  end


  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email
    user.name  = auth.info.name
    user.password = Devise.friendly_token[0, 20] if user.new_record?
    user.email_verified_at ||= Time.current
    user.role ||= :user
    user.save!
    user
  end
end
