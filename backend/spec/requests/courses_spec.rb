require 'rails_helper'

RSpec.describe "Courses", type: :request do
  let(:creator) { create(:user, password: "password123", password_confirmation: "password123", role: 'creator') }
  let(:token) { JsonWebToken.encode(user_id: creator.id) }
  let(:student) { create(:user, password: "password123", password_confirmation: "password123", role: 'student') }
  let(:student_token) { JsonWebToken.encode(user_id: student.id) }
  let!(:course1) { create(:course, creator: creator) }
  let!(:course2) { create(:course, creator: creator) }
  let(:creator_headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:student_headers) { { 'Authorization' => "Bearer #{student_token}" } }

  describe "GET /index" do
    it "returns all courses for all users" do
      get '/courses', headers: student_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      titles = json.map { |c| c['title'] }
      expect(titles).to include(course1.title, course2.title)
    end

    it "returns empty array when no courses exist" do
      Course.delete_all
      get '/courses', headers: student_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end
  end

  describe "GET /show" do
    it "returns the specific course" do
      get "/courses/#{course1.id}", headers: student_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['title']).to eq(course1.title)
      expect(json['description']).to eq(course1.description)
      expect(json['price']).to eq(course1.price)
    end

    it "returns not found for invalid course id" do
      get "/courses/9999", headers: student_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found when no courses exist" do
      Course.delete_all
      get "/courses/#{course1.id}", headers: student_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    let(:valid_attributes) { { title: 'New Course', description: 'Course Description', price: 100 } }
    let(:invalid_attributes) { { title: '', description: 'Course Description', price: 100 } }

    it "creates a new course with valid attributes and athorize user" do
      post '/courses', params: valid_attributes, headers: creator_headers
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['title']).to eq('New Course')
      expect(json['description']).to eq('Course Description')
      expect(json['price']).to eq(100)
    end

    it "create course fails for unauthorized user" do
      post '/courses', params: valid_attributes, headers: student_headers
      expect(response).to have_http_status(:forbidden)
    end

    it "returns errors with invalid attributes" do
      post '/courses', params: invalid_attributes, headers: creator_headers
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['title']).to include("can't be blank")
    end
  end

  describe "PUT /update" do
    let(:valid_attributes) { { title: 'Updated Course' } }
    let(:invalid_attributes) { { title: '' } }
    let(:other_creator) { create(:user, password: "password123", password_confirmation: "password123", role: 'creator') }
    let(:other_token) { JsonWebToken.encode(user_id: other_creator.id) }

    it "updates the course with valid attributes and authorize user" do
      put "/courses/#{course1.id}", params: valid_attributes, headers: creator_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['title']).to eq('Updated Course')
    end

    it "update course fails for different creator" do
      put "/courses/#{course1.id}", params: valid_attributes, headers: { 'Authorization' => "Bearer #{other_token}" }
      expect(response).to have_http_status(:forbidden)
    end

    it "update course fails for unauthorized user" do
      put "/courses/#{course1.id}", params: valid_attributes, headers: student_headers
      expect(response).to have_http_status(:forbidden)
    end

    it "returns errors with invalid attributes" do
      put "/courses/#{course1.id}", params: invalid_attributes, headers: creator_headers
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json['title']).to include("can't be blank")
    end

    it "returns not found for invalid course id" do
      put "/courses/9999", params: valid_attributes, headers: creator_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found when no courses exist" do
      Course.delete_all
      put "/courses/#{course1.id}", params: valid_attributes, headers: creator_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /destroy" do
    let(:other_creator) { create(:user, password: "password123", password_confirmation: "password123", role: 'creator') }
    let(:other_token) { JsonWebToken.encode(user_id: other_creator.id) }

    it "deletes the course and authorize user" do
      delete "/courses/#{course1.id}", headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:no_content)
      expect(Course.find_by(id: course1.id)).to be_nil
    end

    it "delete course fails for different creator" do
      delete "/courses/#{course1.id}", headers: { 'Authorization' => "Bearer #{other_token}" }
      expect(response).to have_http_status(:forbidden)
    end

    it "delete course fails for unauthorized user" do
      delete "/courses/#{course1.id}", headers: student_headers
      expect(response).to have_http_status(:forbidden)
    end

    it "returns not found for invalid course id" do
      delete "/courses/9999", headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found when no courses exist" do
      Course.delete_all
      delete "/courses/#{course1.id}", headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:not_found)
    end
  end
end
