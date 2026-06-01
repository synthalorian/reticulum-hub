class ApiToken < ApplicationRecord
  has_secure_token :plain_token, length: 48

  before_create :digest_token

  validates :name, presence: true

  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def self.authenticate(raw_token)
    digest = OpenSSL::HMAC.hexdigest("SHA256", Rails.application.credentials.secret_key_base, raw_token)
    token = find_by(token_digest: digest)
    return nil if token && token.expires_at && token.expires_at <= Time.current
    token
  end

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end

  private

  def digest_token
    self.token_digest = OpenSSL::HMAC.hexdigest("SHA256", Rails.application.credentials.secret_key_base, plain_token)
  end
end
