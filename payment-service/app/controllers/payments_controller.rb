class PaymentsController < ApplicationController

  def create
    payment_service = StripeService.new(params[:user_id])
    result = payment_service.process_payment(
      enrollment_id: params[:enrollment_id],
      stripe_token: params[:stripe_token],
      amount: params[:amount]
    )

    if result[:success]
      render json: result, status: :ok
    else
      render json: result, status: :unprocessable_entity
    end
  end
end
