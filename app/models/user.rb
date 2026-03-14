class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  enum :role, { user: 0, cs: 1, admin: 2 }

  scope :sellers, -> { where(is_seller: true) }

  has_many :otps, dependent: :destroy
  has_many :listings
  has_many :orders, foreign_key: :buyer_id, dependent: :nullify
  has_many :bids, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :coin_deposits, dependent: :destroy
  has_many :withdrawal_requests, dependent: :destroy
  has_many :coin_transactions, dependent: :destroy
  has_many :watchlists, dependent: :destroy
  has_many :watched_listings, through: :watchlists, source: :listing

  has_one_attached :avatar

  COIN_EXCHANGE_RATE = 1000 # 1000 VND = 1 SnapBid Coin

  after_initialize do
    self.role ||= :user if new_record?
  end

  # ── Display helpers ──────────────────────────────────────────────────────
  def display_name
    name.presence || email
  end

  def seller?
    is_seller?
  end

  # ── Account lock helpers ────────────────────────────────────────────────
  def locked?
    locked_at.present?
  end

  def lock_account!(reason: nil)
    update!(locked_at: Time.current)
  end

  def unlock_account!
    update!(locked_at: nil)
  end

  # ── Coin helpers ─────────────────────────────────────────────────────────
  def coin_balance
    snapbid_coins
  end

  # Ghi nhận thay đổi coin và tạo log CoinTransaction
  # force: true - bypass lock check (dùng cho admin/webhook)
  def process_coin_transaction!(amount:, transaction_type:, description: nil, subject: nil, force: false)
    return if amount == 0
    raise "User account is locked" if locked? && !force
    
    ActiveRecord::Base.transaction do
      if amount > 0
        increment!(:snapbid_coins, amount)
      else
        raise "Insufficient SnapBid Coins" if snapbid_coins < amount.abs
        decrement!(:snapbid_coins, amount.abs)
      end

      coin_transactions.create!(
        amount: amount,
        balance_after: snapbid_coins,
        transaction_type: transaction_type,
        description: description,
        subject: subject
      )
    end
  end

  # Ref dùng trong nội dung chuyển khoản để nạp coin
  def deposit_ref
    "SBC#{id}"
  end

  # Credit coins sau khi nhận được VND (1000 VND = 1 coin)
  # force: true - bypass lock check (dùng cho webhook)
  def credit_coins!(amount_vnd:, transaction_id: nil, force: true)
    coins = (amount_vnd.to_i / COIN_EXCHANGE_RATE).to_i
    return 0 if coins <= 0

    ActiveRecord::Base.transaction do
      process_coin_transaction!(
        amount: coins,
        transaction_type: :deposit,
        description: "Nạp #{coins} coin từ chuyển khoản",
        force: force
      )
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

  # Deduct coins to pay for an order (Legacy)
  def deduct_coins!(amount_coins)
    process_coin_transaction!(
      amount: -amount_coins,
      transaction_type: :payment,
      description: "Thanh toán hoá đơn hoặc trừ phí hệ thống"
    )
  end

  # Coins needed to buy at price (VND)
  def self.vnd_to_coins(vnd)
    (vnd.to_d / COIN_EXCHANGE_RATE).ceil
  end

  def coins_spent_on_listing(listing_id)
    count = bids.where(listing_id: listing_id).count
    return 0 if count == 0
    5 + (count - 1) * 1
  end

  def coins_needed_for_next_bid(listing_id)
    bids.where(listing_id: listing_id).exists? ? 1 : 5
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
