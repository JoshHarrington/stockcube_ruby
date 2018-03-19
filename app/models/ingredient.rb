class Ingredient < ApplicationRecord
	belongs_to :unit, optional: true
	has_many :portions
	has_many :recipes, through: :portions
	has_many :stocks
	has_many :cupboards, through: :stocks
	has_many :shopping_list_portions
	has_many :shopping_lists, through: :shopping_list_portions

	accepts_nested_attributes_for :recipes
	accepts_nested_attributes_for :portions
	accepts_nested_attributes_for :unit,
				:reject_if => :all_blank
end
