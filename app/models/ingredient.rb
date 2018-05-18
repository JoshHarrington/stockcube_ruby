class Ingredient < ApplicationRecord
	belongs_to :unit, optional: true
	has_many :portions, inverse_of: :ingredient
	has_many :recipes, through: :portions
	has_many :stocks
	has_many :cupboards, through: :stocks
	has_many :shopping_list_portions
	has_many :shopping_lists, through: :shopping_list_portions

	# accepts_nested_attributes_for :unit, :stocks, :portions, :recipes, :cupboards
end
