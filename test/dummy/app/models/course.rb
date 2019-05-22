class Course < ApplicationRecord
  include Jsonapi::Fster::ActAsFilter
  has_many :sessions
  has_many :categories_courses
  has_many :categories, through: :categories_courses
  has_many :amenities
  has_one :department
  belongs_to :studio
end
