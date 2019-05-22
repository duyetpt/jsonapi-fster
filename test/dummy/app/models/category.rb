class Category < ApplicationRecord
  include Jsonapi::Fster::ActAsFilter
  has_many :categories_courses
  has_many :courses, through: :categories_courses
end
