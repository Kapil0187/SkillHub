class ProfilesController < ApplicationController
  before_action :authenticate_request!

  def show
    render json: { id: current_user.id, email: current_user.email }
  end
end
