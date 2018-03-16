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

	def shopping_list_portions_output(ingredient_id)
		ingredient_name = Ingredient.where(id: ingredient_id).first.name
		portion_unit_number = ShoppingListPortion.where(ingredient_id: ingredient_id).first.unit_number
		unit = Unit.where(id: portion_unit_number).first
		portion_amount = ShoppingListPortion.where(ingredient_id: ingredient_id).sum(:amount).to_i

		# if unit.name == "Each" || unit.name == "Side"
		if unit.unit_number == 5 || unit.unit_number == 44
			return portion_amount.to_s + ' ' + ingredient_name.pluralize(portion_amount.to_i)
		else
			if unit.short_name
				if unit.name.downcase.include?("milliliter")
					return portion_amount.to_s + unit.short_name.downcase.to_s + ' ' + ingredient_name.to_s
				else
					return portion_amount.to_s + ' ' + unit.name.to_s + ' ' + ingredient_name.to_s
				end
			else
				unit.name = unit.name.pluralize(portion_amount.to_i)
				return portion_amount.to_s + ' ' + unit.name.to_s + ' ' + ingredient_name.to_s
			end
		end
	end
	def portion_unit_metric_transform(shopping_list_portion, portion_unit_obj, portion_obj, ingredient_obj)
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
