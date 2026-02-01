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

  # # Authentication token methods
  # def self.encode_auth_token(user_id)
  #   payload = { user_id: user_id, exp: 24.hours.from_now.to_i }
  #   JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  # end

  # def self.decode_auth_token(token)
  #   decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
  #   user_id = decoded[0]['user_id']
    
  #   # Kiểm tra hạn sử dụng
  #   exp = decoded[0]['exp']
  #   return nil if Time.current.to_i > exp.to_i
    
  #   user_id
  # rescue
  #   nil
  # end
end
