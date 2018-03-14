module ShoppingListsHelper
	def shoppingListIndex(shopping_list)
		userShoppingLists = current_user.shopping_lists
		plain_index = userShoppingLists.index(shopping_list)
		final_index = plain_index + 1
		final_index
	end
	def ingredientsIn(recipes)
		recipes.each do |recipe|
			recipe.portions.each do |portion|
				same_ingredients = Portion.where(ingredient_id: portion.ingredient_id, unit_number: portion.unit_number)
				total_portion_amount = 0
				same_ingredients.each do |ingredient|
					total_portion_amount += ingredient.amount
					total_portion_amount.to_s + portion.ingredient.unit.name.to_s + ' of ' + portion.ingredient.name.to_s + '\n'
				end
			end
		end
	end
end
