class Ingredient < ApplicationRecord
	has_many :portions
	has_many :stocks
	has_many :recipes, through: :portions
	has_many :cupboards, through: :stocks
end
