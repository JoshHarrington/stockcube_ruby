module RecipesHelper
	def recipe_description
		description = @recipe.description
		description.gsub!(/\n/, '<br />').html_safe
	end
end
