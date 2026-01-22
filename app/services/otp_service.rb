class OtpService
  TTL = 10.minutes

  def self.generate!(user, purpose:)
    code = rand(100_000..999_999).to_s
    digest = BCrypt::Password.create(code)

    otp = user.otps.create!(
      purpose: purpose,
      code_digest: digest,
      expires_at: Time.current + TTL
    )

    [otp, code]
  end

  def self.verify!(user, purpose:, code:)
    otp = user.otps.where(purpose: purpose, used_at: nil).order(created_at: :desc).first
    return false if otp.nil? || Time.current > otp.expires_at

    ok = BCrypt::Password.new(otp.code_digest) == code
    otp.update!(used_at: Time.current) if ok
    ok
  end
end
