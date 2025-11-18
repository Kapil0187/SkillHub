class UsersController < ApplicationController
  before_action :authenticate_request!

  def show
    authorize current_user
    render json: { id: current_user.id, email: current_user.email , role: current_user.role}
  end
end
