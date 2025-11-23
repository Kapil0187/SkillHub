require "httparty"

class PaymentService
  def initialize(user)
    @user = user
  end

  def process_payment(enrollment_id, token, amount)
    @enrollment = Enrollment.find(enrollment_id)
    if @enrollment.nil?
      raise "Enrollment not found"
    end

    response = HTTParty.post(
      "#{ENV['PAYMENT_MICROSERVICE_URL']}/payments",
      headers: { "Content-Type" => "application/json" },
      body: {
        user_id: @user.id,
        enrollment_id: @enrollment.id,
        stripe_token: token,
        amount: amount
      }.to_json
    )

    if response.parsed_response["success"]
      @enrollment.update(status: "completed")
    else
      @enrollment.update(status: "cancelled")
    end
  end
end
