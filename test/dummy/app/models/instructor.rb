class Instructor < ApplicationRecord
  include Jsonapi::Fster::ActAsFilter
  has_one :session
end
