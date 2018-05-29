module ShoppingListsHelper
	def shoppingListIndex(shopping_list)
		userShoppingLists = current_user.shopping_lists
		zero_base_index = userShoppingLists.index(shopping_list)
		return zero_base_index + 1
	end

	def metric_transform(portion_obj, portion_unit_obj)
		metric_amount = portion_obj.amount * portion_unit_obj.metric_ratio

		if metric_amount < 20
			return metric_amount = metric_amount.ceil
		elsif metric_amount < 400
			return metric_amount = (metric_amount / 10).ceil * 10
		elsif metric_amount < 1000
			return metric_amount = (metric_amount / 20).ceil * 20
		else
			return metric_amount = (metric_amount / 50).ceil * 50
		end
	end

	def metric_transform_portion_update(shopping_list_portion, portion_unit_obj, portion_obj, ingredient_obj)
		if portion_unit_obj.metric_ratio

			metric_amount = portion_obj.amount * portion_unit_obj.metric_ratio
			metric_transform(portion_obj, portion_unit_obj)

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

	def latest_shopping_list_path
		latest_shopping_list = current_user.shopping_lists.order('created_at DESC').first
		return shopping_list_ingredients_path(latest_shopping_list)
	end

	def shopping_list_latest(shopping_list)
		latest_shopping_list = current_user.shopping_lists.order('created_at DESC').first
		if shopping_list.id == latest_shopping_list.id
			return true
		else
			return false
		end
	end
end
