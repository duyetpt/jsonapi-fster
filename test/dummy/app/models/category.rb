class Category < ApplicationRecord
  include Jsonapi::Fster::ActAsFilter
  include Jsonapi::Fster::ActAsSorting
  has_many :categories_courses
  has_many :courses, through: :categories_courses
end
