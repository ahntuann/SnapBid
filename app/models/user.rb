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
  has_many :coin_deposits, dependent: :destroy

  has_one_attached :avatar

  COIN_EXCHANGE_RATE = 1000 # 1000 VND = 1 SnapBid Coin

  after_initialize do
    self.role ||= :user if new_record?
  end

  # ── Coin helpers ─────────────────────────────────────────────────────────
  def coin_balance
    snapbid_coins
  end

  # Ref dùng trong nội dung chuyển khoản để nạp coin
  def deposit_ref
    "SBC#{id}"
  end

  # Credit coins sau khi nhận được VND (1000 VND = 1 coin)
  def credit_coins!(amount_vnd:, transaction_id: nil)
    coins = (amount_vnd.to_i / COIN_EXCHANGE_RATE).to_i
    return 0 if coins <= 0

    ActiveRecord::Base.transaction do
      increment!(:snapbid_coins, coins)
      coin_deposits.create!(
        amount_vnd: amount_vnd.to_i,
        coins_credited: coins,
        deposit_ref: deposit_ref,
        sepay_transaction_id: transaction_id,
        credited_at: Time.current
      )
    end
    coins
  end

  # Deduct coins to pay for an order
  def deduct_coins!(amount_coins)
    raise "Insufficient SnapBid Coins" if snapbid_coins < amount_coins
    decrement!(:snapbid_coins, amount_coins)
  end

  # Coins needed to buy at price (VND)
  def self.vnd_to_coins(vnd)
    (vnd.to_d / COIN_EXCHANGE_RATE).ceil
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
