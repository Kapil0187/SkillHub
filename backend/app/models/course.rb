class Course < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "user_id"
  validates :title, presence: true
  validates :description, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
