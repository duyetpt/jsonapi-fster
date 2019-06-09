class Studio < ApplicationRecord
  include Jsonapi::Fster::ActAsFilter
  belongs_to :district, optional: true
end
