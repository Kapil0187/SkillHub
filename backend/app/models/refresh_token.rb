class RefreshToken < ApplicationRecord
  belongs_to :user
  before_create :generate_token

  def expired?
    Time.now > expires_at
  end

  private

  def generate_token
    self.token = SecureRandom.hex(64)
    self.expires_at ||= Time.now + Rails.application.credentials.dig(:jwt, :refresh_exp)
  end
end
