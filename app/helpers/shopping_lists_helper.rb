module ShoppingListsHelper
	def recipesNotInList(shopping_list)
		@recipes = Recipe.all
		@recipes_in_list = shopping_list.recipes
		@recipes.delete(@recipes_in_list)
	end
	def recipes
		Recipe.all
	end
	def shoppingListIndex(shopping_list)
		userShoppingLists = current_user.shopping_lists
		plain_index = userShoppingLists.index(shopping_list)
		final_index = plain_index + 1
		final_index
	end
end
