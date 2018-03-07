class Unit < ApplicationRecord
  has_many :portions
  has_many :stocks
  has_many :ingredients
end
