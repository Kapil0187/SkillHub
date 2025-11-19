class ApiController < ActionController::API
  include Pundit::Authorization 
  include ErrorHandler

  private

  def authenticate_request!
    token = token_from_header
    payload = JsonWebToken.decode(token)
    @current_user = User.find_by(id: payload[:user_id])
    render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user = @current_user || begin
      token = token_from_header
      payload = JsonWebToken.decode(token)
      User.find_by(id: payload[:user_id])
    end
  end

  def token_from_header
    auth = request.headers['Authorization']
    if auth.present? && auth[/\ABearer /i]
      auth.split(' ').last
    else
      raise JWT::DecodeError, 'Missing or malformed Authorization header'
    end
  end
end
