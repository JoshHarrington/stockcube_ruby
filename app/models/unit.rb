class Unit < ApplicationRecord
  has_many :ingredients
  has_many :portions, through: :ingredients
  has_one :stock

  accepts_nested_attributes_for :portions,
  :reject_if => :all_blank,
  :allow_destroy => true
  accepts_nested_attributes_for :ingredients
end
