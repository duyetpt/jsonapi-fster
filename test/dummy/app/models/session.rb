class Session < ApplicationRecord
  include Jsonapi::Fster::ActAsFilter
  belongs_to :course
  has_one :instructor
end
