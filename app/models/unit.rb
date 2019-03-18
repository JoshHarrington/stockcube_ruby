class Unit < ApplicationRecord
  has_many :ingredients
  has_one :portion
  has_one :stock
  has_one :user_fav_stock
end
