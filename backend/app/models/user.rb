class User < ApplicationRecord
  has_secure_password
  has_many :refresh_tokens, dependent: :destroy
  validates :email, presence: true, uniqueness: true

  enum :role, { student: "student", creator: "creator", admin: "admin" }, default: "student"
end
