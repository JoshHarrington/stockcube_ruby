module PlannerShoppingListHelper
	include IngredientsHelper
	def add_planner_recipe_to_shopping_list(planner_recipe = nil)
		return if planner_recipe == nil
		planner_shopping_list = PlannerShoppingList.find_or_create_by(user_id: current_user.id)

		recipe_portions = planner_recipe.recipe.portions.reject{|p| p.ingredient.name.downcase == 'water'}
		ingredients_from_recipe_portions = recipe_portions.map(&:ingredient_id)

		cupboards = CupboardUser.where(user_id: current_user.id, accepted: true).map{|cu| cu.cupboard unless cu.cupboard.setup == true || cu.cupboard.hidden == true }.compact.sort_by{|c| c.created_at}.reverse!
		stock = cupboards.map{|c| c.stocks.select{|s| s.use_by_date > Date.current - 4.days && s.ingredient.name.downcase != 'water' && s.planner_recipe_id == nil }}.flatten.compact
		ingredients_from_stock = stock.map(&:ingredient_id)

		uncommon_ingredients = ingredients_from_recipe_portions - ingredients_from_stock

		if ingredients_from_recipe_portions && ingredients_from_stock.length > 0
			common_ingredients = ingredients_from_recipe_portions & ingredients_from_stock
			common_ingredients.each do |ing|
				stock_from_ing = stock.select{|s| s.ingredient_id == ing}.first
				## find the highest amount of stock
				portion_from_ing = recipe_portions.select{|p| p.ingredient_id == ing}.first

				ingredient_plus_diff_amount = ingredient_plus_difference(stock_from_ing, portion_from_ing)
				if stock_from_ing.unit_id == portion_from_ing.unit_id
					unit_id = portion_from_ing.unit_id
				elsif ingredient_unit_type_match(stock_from_ing, portion_from_ing) && ingredient_metric_check(stock_from_ing) && ingredient_metric_check(portion_from_ing)
					unit_id = default_unit_id(portion_from_ing)
				else
					unit_id = portion_from_ing.unit_id
				end

				if ingredient_plus_diff_amount
					if ingredient_plus_diff_amount <= 0
						stock_from_ing.update_attributes(
							planner_recipe_id: planner_recipe.id
						)
						## original stock updated
						if ingredient_plus_diff_amount < 0
							## when amount < 0 new stock is needed so shopping list portion should be created at the same time
							PlannerShoppingListPortion.create(
								user_id: current_user.id,
								planner_recipe_id: planner_recipe.id,
								ingredient_id: ing,
								unit_id: unit_id,
								amount: -(ingredient_plus_diff_amount),
								planner_shopping_list_id: planner_shopping_list.id
							)
						end
					elsif ingredient_plus_diff_amount > 0
						recipe_stock = Stock.create(
							ingredient_id: ing,
							amount: ingredient_plus_converter(portion_from_ing),
							planner_recipe_id: planner_recipe.id,
							unit_id: unit_id,
							use_by_date: stock_from_ing.use_by_date,
							cupboard_id: stock_from_ing.cupboard_id,
							hidden: false,
							always_available: false
						)
						current_user.stocks << recipe_stock
						ingredient_plus_hash = {
							unit_metric_ratio: stock_from_ing.unit.metric_ratio,
							unit_type: stock_from_ing.unit.unit_type,
							amount: ingredient_plus_diff_amount
						}

						stock_from_ing.update_attributes(
							unit_id: unit_id,
							amount: ingredient_plus_diff_amount
						)

					end
				else
					uncommon_ingredients.push(ing)
				end
			end
		end

		uncommon_ingredients.each do |uc_ing|
			portion_from_uc_ing = recipe_portions.select{|p| p.ingredient_id == uc_ing}.first
			PlannerShoppingListPortion.create(
				user_id: current_user.id,
				planner_recipe_id: planner_recipe.id,
				ingredient_id: uc_ing,
				unit_id: portion_from_uc_ing.unit_id,
				amount: portion_from_uc_ing.amount,
				planner_shopping_list_id: planner_shopping_list.id
			)
		end

	end

	def update_planner_shopping_list_portions
		planner_shopping_list = PlannerShoppingList.find_or_create_by(user_id: current_user.id)
		planner_shopping_list_portions = planner_shopping_list.planner_shopping_list_portions.select{|p|p.planner_recipe.date >= Date.current}.sort_by{|p|p.planner_recipe.date}
		ingredients_from_planner_shopping_list = planner_shopping_list_portions.map(&:ingredient_id)
		planner_shopping_list.combi_planner_shopping_list_portions.destroy_all

		matching_ingredients = ingredients_from_planner_shopping_list.select{ |e| ingredients_from_planner_shopping_list.count(e) > 1 }.uniq
		if matching_ingredients.length > 0
			matching_ingredients.each do |m_ing|
				matching_sl_portions = planner_shopping_list_portions.select{|p| p.ingredient_id == m_ing}

				if ingredient_plus_addition(matching_sl_portions) == false
					next
				end

				combi_addition_object = ingredient_plus_addition(matching_sl_portions)
				combi_amount = combi_addition_object[:amount]
				combi_unit_id = combi_addition_object[:unit_id]

				combi_sl_portion = CombiPlannerShoppingListPortion.find_or_create_by(
					user_id: current_user[:id],
					planner_shopping_list_id: planner_shopping_list.id,
					ingredient_id: m_ing,
					amount: combi_amount,
					unit_id: combi_unit_id,
					date: matching_sl_portions.last.planner_recipe.date
				)

				PlannerShoppingListPortion.where(id: matching_sl_portions.map(&:id)).update_all(
					combi_planner_shopping_list_portion_id: combi_sl_portion[:id]
				)

			end
		end
	end


	def combine_divided_stock_after_planner_recipe_delete(planner_recipe = nil)
		return if planner_recipe == nil || planner_recipe.stocks.length < 1
		planner_recipe.stocks.where('stocks.updated_at > ?', Date.current - 1.hour).each do |stock|
			stock_partner = stock.cupboard.stocks.where.not(id: stock.id).find_by(ingredient_id: stock.ingredient_id, use_by_date: stock.use_by_date)
			return unless stock_partner.present?
			stock_group = [stock_partner, stock]
			if ingredient_plus_addition(stock_group)
				stock_addition_hash = ingredient_plus_addition(stock_group)
				stock_amount = stock_addition_hash[:amount]
				stock_unit_id = stock_addition_hash[:unit_id]
				stock_partner.update_attributes(
					amount: stock_amount,
					unit_id: stock_unit_id
				)
				stock.delete
			else
				stock.update_attributes(
					planner_recipe_id: nil
				)
			end

		end
	end
end
