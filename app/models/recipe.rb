class Recipe < ApplicationRecord
	has_many :portions
	has_many :ingredients, through: :portions
	has_many :favourites
	has_many :users, through: :favourites


  accepts_nested_attributes_for :portions,
           :reject_if => :all_blank,
           :allow_destroy => true
  accepts_nested_attributes_for :ingredients
end

