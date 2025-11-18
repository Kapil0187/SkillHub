require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  let(:user) { create(:user, password: "password123", password_confirmation: "password123", role: 'student') }
  
  describe "POST /signup" do
      let(:valid_attributes) { { email: 'test@gmail.com', password: 'password123', password_confirmation: 'password123', role:'student' } }
      let(:invalid_attributes) { { email: 'test@gmail.com', password: 'password123', password_confirmation: 'wrongconfirmation', role:'student' } }

      it 'creates a new user with valid attributes' do
        post '/signup', params: valid_attributes

        expect(response).to  have_http_status(201)
        json = JSON.parse(response.body)
        expect(json['access_token']).to be_present
        expect(json['refresh_token']).to be_present
        expect(json['user']['email']).to eq('test@gmail.com')
        expect(json['user']['role']).to eq('student')
      end

      it 'returns errors with invalid attributes' do
        post '/signup', params: invalid_attributes

        expect(response).to have_http_status(422)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Password confirmation doesn't match Password")
      end
    end

  describe "POST /login" do
    it 'authenticates user with valid credentials' do
      post '/login', params: { email: user.email, password: 'password123' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['access_token']).to be_present
      expect(json['refresh_token']).to be_present
      expect(json['user']['email']).to eq(user.email)
    end

    it 'returns error with invalid credentials' do
      post '/login', params: { email: user.email, password: 'wrongpassword' }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid email/password')
    end
  end

  describe "POST /logout" do
    let(:refresh_token) { user.refresh_tokens.create! }

    it 'logs out user with valid refresh token' do
      post '/logout', params: { refresh_token: refresh_token.token }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Logged out successfully')
      expect(RefreshToken.find_by(token: refresh_token.token)).to be_nil
    end

    it 'returns error with invalid refresh token' do
      post '/logout', params: { refresh_token: 'invalidtoken' }

      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid refresh token')
    end
  end

  describe "POST /refresh" do
    let(:refresh_token) { user.refresh_tokens.create! }

    it 'refreshes access token with valid refresh token' do
      post '/refresh', params: { refresh_token: refresh_token.token }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['access_token']).to be_present
    end

    it 'returns error with invalid refresh token' do
      post '/refresh', params: { refresh_token: 'invalidtoken' }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid or expired refresh token')
    end
  end
end
