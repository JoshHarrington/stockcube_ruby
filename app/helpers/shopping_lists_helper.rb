module ShoppingListsHelper
	def shoppingListIndex(shopping_list)
		userShoppingLists = current_user.shopping_lists
		plain_index = userShoppingLists.index(shopping_list)
		final_index = plain_index + 1
		final_index
	end

	def shopping_list_portions_output(ingredient_id, shopping_list_id)
		ingredient_name = Ingredient.where(id: ingredient_id).first.name
		portion_unit_number = ShoppingListPortion.where(ingredient_id: ingredient_id, shopping_list_id: shopping_list_id).first.unit_number
		unit = Unit.where(id: portion_unit_number).first
		portion_amount = ShoppingListPortion.where(ingredient_id: ingredient_id, shopping_list_id: shopping_list_id).sum(:amount).to_i

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

	def stock_in_cupboard_proportion(ingredient_id, shopping_list_id, cupboard_stock_ids)
		ingredient = Ingredient.where(id: ingredient_id).first

		cupboard_stocks = Stock.find(cupboard_stock_ids)

		cupboard_stock_amount = 0

		cupboard_stocks.each do |stock|
			if stock.ingredient_id == ingredient_id
				cupboard_stock_find = Stock.where(id: stock.id).first
				cupboard_stock_amount += cupboard_stock_find.amount
			end
		end

		if cupboard_stock_amount != 0
			portion_obj = Stock.where(ingredient_id: ingredient_id).first
			portion_unit_obj = portion_obj.ingredient.unit
			if portion_unit_obj.metric_ratio
				metric_transform(portion_obj, portion_unit_obj)
			end
		end

		portion_first_obj = ShoppingListPortion.where(ingredient_id: ingredient_id, shopping_list_id: shopping_list_id).first
		portion_amount = ShoppingListPortion.where(ingredient_id: ingredient_id, shopping_list_id: shopping_list_id).sum(&:amount).to_i
		portion_unit = Unit.where(unit_number: portion_first_obj.unit_number).first

		if cupboard_stock_amount != 0
			proportion_in_cupboard = cupboard_stock_amount / portion_amount
			if proportion_in_cupboard < 1
				return cupboard_stock_amount.to_s + " " + portion_unit.name + " already in cupboard"
			elsif proportion_in_cupboard.to_floor < 2
				return "More than enough in cupboard already"
			else
				return "More than enough in cupboard, about " + proportion_in_cupboard.to_floor.to_s + " times more than you need"
			end
		else
			return "Not in cupboards"
		end

	end

	def metric_transform(portion_obj, portion_unit_obj)
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
end
