class Unit < ApplicationRecord
  has_many :ingredients
  has_many :portions, through: :ingredients
  has_many :stocks, through: :ingredients

  accepts_nested_attributes_for :stocks,
  :reject_if => :all_blank,
  :allow_destroy => true
  accepts_nested_attributes_for :ingredients
end
