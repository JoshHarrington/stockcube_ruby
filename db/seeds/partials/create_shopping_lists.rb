admin_user = User.where(admin: true).first

picked_recipes = Recipe.all.sample(3)

shopping_list_1 = ShoppingList.create

admin_user.shopping_lists << shopping_list_1

shopping_list_1.recipes << picked_recipes

shopping_list_portion_ids = []

shopping_list_1.recipes.each do |recipe|
	recipe.portions.each do |portion|
		shopping_list_portion_ids.push(portion.id)
	end
end

shopping_list_portion_ids.each do |portion_id|
	portion_obj = Portion.where(id: portion_id).first
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
					:amount => metric_amount,
					:recipe_number => portion_obj.recipe_id
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
					:unit_number => portion_obj.unit_number,
					:recipe_number => portion_obj.recipe_id
				)
			end
		end
	end
end
