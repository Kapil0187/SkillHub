class JsonWebToken
  ALGORITHM = 'HS256'.freeze

  def self.secret
    Rails.application.credentials.dig(:jwt, :secret)
  end

  def self.encode(payload, exp = nil)
    payload = payload.dup
    exp ||= Rails.application.credentials.dig(:jwt, :exp)
    payload[:exp] = (Time.now + exp).to_i
    JWT.encode(payload, secret, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret, true, algorithm: ALGORITHM)
    HashWithIndifferentAccess.new(decoded[0])
  rescue JWT::ExpiredSignature
    raise JWT::ExpiredSignature
  rescue JWT::DecodeError => e
    raise e
  end
end
