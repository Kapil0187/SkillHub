require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  describe "GET /user" do
    it "return the user of the authenticated user" do
      get '/user', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['email']).to eq(user.email)
    end

    it "returns unauthorized without a valid token" do
      get '/user', headers: { 'Authorization' => "Bearer #{'invalidtoken'}" }
      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Unauthorized')
    end
  end
end
