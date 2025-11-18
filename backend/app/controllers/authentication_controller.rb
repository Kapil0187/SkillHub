class AuthenticationController < ApplicationController
  # POST /signup
  def signup
    user = User.new(signup_params)
    if user.save
      access_token = JsonWebToken.encode(user_id: user.id)
      refresh_token = user.refresh_tokens.create!
      render json: { access_token: access_token, refresh_token: refresh_token.token, user: { id: user.id, email: user.email, role: user.role } }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    user = User.find_by(email: params[:email].to_s.downcase)
    if user&.authenticate(params[:password])
      access_token = JsonWebToken.encode(user_id: user.id)
      refresh_token = user.refresh_tokens.create!
      render json: { access_token: access_token, refresh_token: refresh_token.token, user: { id: user.id, email: user.email, role: user.role } }
    else
      render json: { error: 'Invalid email/password' }, status: :unauthorized
    end
  end

  # POST /logout
  def logout
    token_str = params[:refresh_token]
    token = RefreshToken.find_by(token: token_str)
    if token
      token.destroy
      render json: { message: 'Logged out successfully' }
    else
      render json: { error: 'Invalid refresh token' }, status: :unprocessable_entity
    end
  end

  # POST /refresh
  def refresh
    token = RefreshToken.find_by(token: params[:refresh_token])
    if token && !token.expired?
      access_token = JsonWebToken.encode(user_id: token.user.id)
      render json: { access_token: access_token }
    else
      render json: { error: 'Invalid or expired refresh token' }, status: :unauthorized
    end
  end

  private

  def signup_params
    params.permit(:email, :password, :password_confirmation, :role)
  end
end
