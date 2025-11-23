class EnrollmentsController < ApiController

  def create
    @enrollment = Enrollment.new(enrollment_params)
    if @enrollment.save
      payment_service = PaymentService.new(current_user).process_payment(@enrollment.id, params[:stripe_token], params[:amount])
      debugger
      if payment_service['success']
        @enrollment.update(status: 'completed')
      else
        @enrollment.update(status: 'cancelled')
      end
      render json: { status: 'success', enrollment: @enrollment }, status: :created
    else
      render json: { status: 'error', errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def enrollment_params
    params.permit(:course_id, :user_id)
  end
end
