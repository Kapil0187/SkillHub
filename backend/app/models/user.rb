class User < ApplicationRecord
  has_secure_password
  has_many :refresh_tokens, dependent: :destroy
  validates :email, presence: true, uniqueness: true

  enum :role, { student: "student", creator: "creator" }, default: "student"
end
