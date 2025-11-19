module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from JWT::DecodeError, with: :render_unauthorized
    rescue_from JWT::ExpiredSignature, with: :render_token_expired
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  end

  private

  def render_unauthorized(e = nil)
    render json: { error: "Unauthorized", message: e&.message }, status: :unauthorized
  end

  def render_token_expired
    render json: { error: "TokenExpired", message: "Access token expired" }, status: :unauthorized
  end

  def user_not_authorized
    render json: { error: "You are not authorized to perform this action" }, status: :forbidden
  end

  def record_not_found
    render json: { error: "Record not found" }, status: :not_found
  end
end
