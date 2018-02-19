class Ingredient < ApplicationRecord
	has_many :portions
	has_many :stocks
	has_many :meals, through: :portions
	has_many :cupboards, through: :stocks
end

# def ingredientNameTidy
# 	ingredient_name = @ingredient.name
# 	ingredient_name.gsub!(/(\b[a-z\s]+),(.*)/,)
# 	ingredient_name.gsub!(/,\s(.*)/, ' (\1)')
# end