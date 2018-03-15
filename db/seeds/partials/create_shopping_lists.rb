admin_user = User.where(admin: true).first

picked_recipes = Recipe.all.sample(3)

shopping_list_1 = ShoppingList.create

admin_user.shopping_lists << shopping_list_1

shopping_list_1.recipes << picked_recipes

shopping_list_portion_ids = []

shopping_list_1.recipes.each do |recipe|
	recipe.portions.each do |portion|

		shopping_list_portion_ids.push(portion.id)
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

# shopping_list_ingredient_ids_set = Set[]

shopping_list_portion_ids.each do |portion_id|
	portion_obj = Portion.where(id: portion_id).first

	#### don't worry about duplicates here, will allow for unique recipes to be associated
	# if not shopping_list_ingredient_ids_set.include(portion_obj.ingredient_id)

	# shopping_list_ingredient_ids_set.add(portion_obj.ingredient_id)


	ingredient_obj = Ingredient.where(id: portion_obj.ingredient_id).first
	if ingredient_obj
		shopping_list_1.ingredients << ingredient_obj

		shopping_list_portion_obj = ShoppingListPortion.where(ingredient_id: ingredient_obj.id, shopping_list_id: shopping_list_1.id)

		portion_unit_obj = Unit.where(id: portion_obj.unit_number).first

		shopping_list_portion_obj.each do |shopping_list_portion|
			if portion_unit_obj.metric_ratio
				metric_amount = portion_obj.amount * portion_unit_obj.metric_ratio
				
				if metric_amount < 20
					metric_amount = metric_amount.ceil
				elsif metric_amount < 400
					metric_amount = (metric_amount / 10).ceil * 10
				elsif metric_amount < 1000
					metric_amount = (metric_amount / 20).ceil * 20
				else
					metric_amount = (metric_amount / 50).ceil * 50
				end

				shopping_list_portion.update_attributes(
					:amount => metric_amount
				)
				if portion_unit_obj.unit_type == "volume" && metric_amount < 1000
					## add unit number for milliliters
					shopping_list_portion.update_attributes(
						:unit_number => 11
					)
				elsif portion_unit_obj.unit_type == "volume" && metric_amount >= 1000
					metric_amount = metric_amount / 1000
					## convert to liters
					shopping_list_portion.update_attributes(
						:unit_number => 12,
						:amount => metric_amount
					)
				elsif portion_unit_obj.unit_type == "mass" && metric_amount < 1000
					## add unit number for grams
					shopping_list_portion.update_attributes(
						:unit_number => 8
					)
				elsif portion_unit_obj.unit_type == "mass" && metric_amount >= 1000
					metric_amount = metric_amount / 1000
					## convert to kilograms
					shopping_list_portion.update_attributes(
						:unit_number => 9,
						:amount => metric_amount
					)
				end
			else
				shopping_list_portion.update_attributes(
					:amount => portion_obj.amount,
					:unit_number => portion_obj.unit_number
				)
			end
			

		end


	
	### convert all portions to either grams or ml
	# if ingredient_obj.unit_id == portion_obj.unit_number
	# 	shopping_list_portion_obj.update_attributes(amount: portion_obj.amount)
	# else

	# 	shopping_list_portion_obj.update_attributes(amount: portion_obj.amount)
	# end
	
	# else
	# end

	end
end

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
# 	shopping_list_1.shopping_list_portion_ids << shopping_list_portion

# 	ingredient_obj = Ingredient.where(name: ingredient.name).first
# 	ingredient_obj.shopping_list_portion_ids << shopping_list_portion
# end


