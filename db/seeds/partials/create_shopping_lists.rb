admin_user = User.where(admin: true).first

picked_recipes = Recipe.all.sample(3)

shopping_list_1 = ShoppingList.create

admin_user.shopping_lists << shopping_list_1

shopping_list_1.recipes << picked_recipes

shopping_list_portions = []

shopping_list_1.recipes.each do |recipe|
	recipe.portions.each do |portion|

		shopping_list_portions << portion.id
		# same_ingredients = Portion.where(recipe_id: portion.recipe_id, ingredient_id: portion.ingredient_id, unit_number: portion.unit_number)
		# total_portion_amount = 0
		# same_ingredients.each_with_index do |ingredient, index|
		# 	total_portion_amount += ingredient.amount
		# 	if same_ingredients.length == index + 1
		# 		shopping_list_portion.update_attributes(
		# 			amount: total_portion_amount
		# 		)
		# 	end
		# end
	end
end

# shopping_list_portions.each do |portion_id|
# 	portion_obj = Portion.where(id: portion_id).first
# end

# -----

# shopping_list_1.recipes.ingredients.each do |ingredient|

# 	total_portion_amount = 0
# 	unit = ingredient.portions.first.unit_number

# 	ingredient.portions.each do |portion|
# 		if portion.unit_number == unit
# 			total_portion_amount += portion.amount
# 		end
# 	end

# 	shopping_list_portion = ShoppingListPortion.create(amount: total_portion_amount)
# 	shopping_list_1.shopping_list_portions << shopping_list_portion

# 	ingredient_obj = Ingredient.where(name: ingredient.name).first
# 	ingredient_obj.shopping_list_portions << shopping_list_portion
# end


