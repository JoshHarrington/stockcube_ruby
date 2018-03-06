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
end
