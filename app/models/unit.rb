class Unit < ApplicationRecord
  has_many :stocks
  has_many :ingredients
  has_many :portions, through: :ingredients
end
