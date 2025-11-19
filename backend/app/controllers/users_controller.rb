class UsersController < ApiController
  before_action :authenticate_request!
  after_action :verify_authorized

  def create
    authorize User
    user = User.new(user_params)
    if user.save
      render json: { id: user.id, email: user.email, role: user.role }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    authorize current_user
    render json: { id: current_user.id, email: current_user.email, role: current_user.role }
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation, :role)
  end
end
