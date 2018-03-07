module RecipesHelper
	def recipe_description
		description = @recipe.description
		description.gsub!(/\n/, '<br />').html_safe
	end
	def vegan?(recipe)
		if recipe.ingredients.none?{ |ingredient| ingredient.vegan == false }
			return true
		end
	end
	def vegetarian?(recipe)
		if recipe.ingredients.none?{ |ingredient| ingredient.vegetarian == false }
			return true
		end
	end
	def gluten_free?(recipe)
		if recipe.ingredients.none?{ |ingredient| ingredient.gluten_free == false }
			return true
		end
	end
	def dairy_free?(recipe)
		if recipe.ingredients.none?{ |ingredient| ingredient.dairy_free == false }
			return true
		end
	end
	def kosher?(recipe)
		if recipe.ingredients.none?{ |ingredient| ingredient.kosher == false }
			return true
		end
	end
	def portion_amount(portion)
		portion_amount = portion.amount.to_r
		if (portion_amount.to_f % 1 == 0)
			portion_amount = portion_amount.to_i
		elsif (portion_amount > 1)
			portion_amount = portion_amount.to_whole_fraction
			portion_amount = portion_amount[0].to_s + ' ' + portion_amount[1].to_s + '/' + portion_amount[2].to_s
		end
		portion_amount
	end
	def portion_unit_and_ingredient(portion)
		portion_unit = portion.ingredient.unit.name
		portion_amount = portion.amount
		ingredient = portion.ingredient.name
		## figure out pluralization at same time, based on portion amount
		if portion_unit == "Each"
			ingredient.pluralize(portion_amount)
		else
			portion_unit = portion_unit.pluralize(portion_amount)
			portion_unit.to_s + ' of ' + ingredient.to_s
		end
	end
end
