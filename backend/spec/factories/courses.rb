FactoryBot.define do
  factory :course do
    title { Faker::Educator.course_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Number.between(from: 0, to: 500) }
    association :creator, factory: :user
  end
end
