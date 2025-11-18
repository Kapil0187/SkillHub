class User < ApplicationRecord
  has_secure_password
  has_many :refresh_tokens, dependent: :destroy
  validates :email, presence: true, uniqueness: true

  enum :role, { student: "student", creator: "creator" }, default: "student"

  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at role]
  end
end
