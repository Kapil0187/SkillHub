require "stripe"

class StripeService

  def initialize(user_id)
    @user_id = user_id
    Stripe.api_key = ENV.fetch("SECRETSTRIPE_API_KEY")
  end

  def process_payment(enrollment_id:, stripe_token:, amount:)
    begin
      charge = Stripe::Charge.create(
        amount: (amount.to_f * 100).to_i,
        currency: "usd",
        source: stripe_token,
        description: "Enrollment payment for user #{@user_id}, enrollment #{enrollment_id}",
        metadata: { user_id: @user_id, enrollment_id: enrollment_id }
      )

      if charge.status == "succeeded"
        { success: true, message: "Payment processed successfully", charge_id: charge.id }
      else
        { success: false, message: "Payment failed at Stripe" }
      end

    rescue Stripe::CardError => e
      { success: false, message: e.message }
    rescue => e
      { success: false, message: "Payment failed: #{e.message}" }
    end
  end
end
