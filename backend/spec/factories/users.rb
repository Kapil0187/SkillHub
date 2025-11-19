FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    role { 'student' }

    factory :creator do
      role { "creator" }
    end
  end
end
