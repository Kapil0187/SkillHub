class ApplicationController < ActionController::API
  include Pundit::Authorization 
  rescue_from JWT::DecodeError, with: :render_unauthorized
  rescue_from JWT::ExpiredSignature, with: :render_token_expired
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized  

  private

  def authenticate_request!
    token = token_from_header
    payload = JsonWebToken.decode(token)
    @current_user = User.find_by(id: payload[:user_id])
    render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def token_from_header
    auth = request.headers['Authorization']
    if auth.present? && auth[/\ABearer /i]
      auth.split(' ').last
    else
      raise JWT::DecodeError, 'Missing or malformed Authorization header'
    end
  end

  def render_unauthorized(e = nil)
    render json: { error: 'Unauthorized', message: e&.message }, status: :unauthorized
  end

  def render_token_expired
    render json: { error: 'TokenExpired', message: 'Access token expired' }, status: :unauthorized
  end

  def user_not_authorized
    render json: { error: "Forbidden" }, status: :forbidden
  end
end
