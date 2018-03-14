module ShoppingListsHelper
	def recipesNotInList(shopping_list)
		@recipes = Recipe.all
		@recipes_in_list = shopping_list.recipes
		@recipes.delete(@recipes_in_list)
	end
	def recipes
		Recipe.all
	end
end
