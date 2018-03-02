class Recipe < ApplicationRecord
	has_many :portions
	has_many :ingredients, through: :portions
  belongs_to :users

  # Favourited by users
  has_many :favourite_recipes # just the 'relationships'
  has_many :favourited_by, through: :favourite_recipes, source: :user # the actual users favouriting a recipe

  accepts_nested_attributes_for :portions,
           :reject_if => :all_blank,
           :allow_destroy => true
  accepts_nested_attributes_for :ingredients
end

