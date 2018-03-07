class Ingredient < ApplicationRecord
	belongs_to :unit, optional: true
	has_many :portions
	has_many :recipes, through: :portions
	has_many :stocks
	has_many :cupboards, through: :stocks
end
