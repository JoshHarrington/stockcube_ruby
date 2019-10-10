require 'pry'

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
				## find the highest amount of stock ?
				stock_from_ing = stock.select{|s| s.ingredient_id == ing}.first

				portions_from_ing = recipe_portions.select{|p| p.ingredient_id == ing}

				portions_sum_from_ing = {}
				if portions_from_ing.length == 0
					next
				else
					portions_sum_from_ing = serving_addition(portions_from_ing)
				end

				serving_diff = serving_difference([stock_from_ing, portions_sum_from_ing])

				if serving_diff != false
					serving_diff_amount = serving_diff[:amount]
					if serving_diff_amount <= 0
						stock_from_ing.update_attributes(
							planner_recipe_id: planner_recipe.id
						)
						## original stock updated
						if serving_diff_amount < 0
							## when amount < 0 new stock is needed so shopping list portion should be created at the same time
							PlannerShoppingListPortion.create(
								user_id: current_user.id,
								planner_recipe_id: planner_recipe.id,
								ingredient_id: ing,
								unit_id: serving_diff[:unit_id],
								amount: -(serving_diff_amount),
								planner_shopping_list_id: planner_shopping_list.id
							)
						end
					elsif serving_diff_amount > 0
						recipe_stock = Stock.create(
							ingredient_id: ing,
							amount: serving_converter(portions_sum_from_ing)[:amount],
							planner_recipe_id: planner_recipe.id,
							unit_id: serving_diff[:unit_id],
							use_by_date: stock_from_ing.use_by_date,
							cupboard_id: stock_from_ing.cupboard_id,
							hidden: false,
							always_available: false
						)
						current_user.stocks << recipe_stock
						serving_hash = {
							metric_ratio: stock_from_ing.unit.metric_ratio,
							unit_type: stock_from_ing.unit.unit_type,
							amount: serving_diff_amount
						}

						stock_from_ing.update_attributes(
							unit_id: serving_diff[:unit_id],
							amount: serving_diff_amount
						)
					end
				else
					uncommon_ingredients.push(ing)
				end
			end
		end

		uncommon_ingredients.each do |uc_ing|
			recipe_portions.select{|p| p.ingredient_id == uc_ing}.each do |portion|
				PlannerShoppingListPortion.create(
					user_id: current_user.id,
					planner_recipe_id: planner_recipe.id,
					ingredient_id: portion.ingredient_id,
					unit_id: portion.unit_id,
					amount: portion.amount,
					planner_shopping_list_id: planner_shopping_list.id
				)
			end
		end

	end

	def update_planner_shopping_list_portions
		return unless current_user
		if current_user.planner_recipes.length == 0
			current_user.combi_planner_shopping_list_portions.destroy_all
			return
		end
		current_user.combi_planner_shopping_list_portions.select{|cp|cp.planner_shopping_list_portions.length == 0 || cp.planner_shopping_list_portions.length == 1 }.map{|cp| cp.destroy}

		planner_shopping_list = PlannerShoppingList.find_or_create_by(user_id: current_user.id)
		planner_shopping_list_portions = planner_shopping_list.planner_shopping_list_portions.select{|p|p.planner_recipe.date >= Date.current}.sort_by{|p|p.planner_recipe.date}
		ingredients_from_planner_shopping_list = planner_shopping_list_portions.map(&:ingredient_id)

		matching_ingredients = ingredients_from_planner_shopping_list.select{ |e| ingredients_from_planner_shopping_list.count(e) > 1 }.uniq
		if matching_ingredients.length > 0
			matching_ingredients.each do |m_ing|
				matching_sl_portions = planner_shopping_list_portions.select{|p| p.ingredient_id == m_ing}

				if serving_addition(matching_sl_portions) == false || matching_sl_portions.map(&:checked).uniq.length != 1
					next
				end
				# planner_shopping_list.combi_planner_shopping_list_portions.select{|cp| cp.ingredient_id == m_ing}.map{|cp| cp.destroy}


				combi_addition_object = serving_addition(matching_sl_portions)
				combi_amount = combi_addition_object[:amount]
				combi_unit_id = combi_addition_object[:unit_id]

				combi_sl_portion = CombiPlannerShoppingListPortion.find_or_create_by(
					user_id: current_user[:id],
					planner_shopping_list_id: planner_shopping_list.id,
					ingredient_id: m_ing
				)

				CombiPlannerShoppingListPortion.where(
					user_id: current_user[:id],
					planner_shopping_list_id: planner_shopping_list.id,
					ingredient_id: m_ing
				).where.not(id: combi_sl_portion[:id]).destroy_all


				combi_sl_portion.update_attributes(
					amount: combi_amount,
					unit_id: combi_unit_id,
					date: matching_sl_portions.last.planner_recipe.date,
					checked: matching_sl_portions.first.checked
				)

				PlannerShoppingListPortion.where(id: matching_sl_portions.map(&:id)).update_all(
					combi_planner_shopping_list_portion_id: combi_sl_portion[:id]
				)

			end
		end

		all_shopping_list_portions = []
		planner_shopping_list_portions.reject{|p| p.combi_planner_shopping_list_portion_id != nil}.map{|p| all_shopping_list_portions.push(p)}
		current_user.combi_planner_shopping_list_portions.select{|cp|cp.date >= Date.current}.map{|cp|all_shopping_list_portions.push(cp)}

		all_shopping_list_portions.each do |p|

			size_diff = false

			# loop over each default ingredient size to find a size bigger than the portion
			# if no size found, double the ingredient size amounts then rerun the loop
			# keep stepping up sizes until correct size found


			planner_portion_size = find_planner_portion_size(p)

			if planner_portion_size != false

				wrapper_portion = PlannerPortionWrapper.find_or_create_by(
					user_id: current_user[:id],
					planner_shopping_list_id: planner_shopping_list.id,
					ingredient_id: p.ingredient_id,
					amount: planner_portion_size[:converted_size][:amount],
					unit_id: planner_portion_size[:converted_size][:unit_id],
					date: p.has_attribute?(:date) ? p.date : p.planner_recipe.date,
					checked: p.checked
				)

				PlannerPortionWrapper.where(
					user_id: current_user[:id],
					planner_shopping_list_id: planner_shopping_list.id,
					ingredient_id: p.ingredient_id
				).where.not(id: wrapper_portion[:id]).destroy_all

				PlannerShoppingListPortion.where(id: p.id).update_all(
					planner_portion_wrapper_id: wrapper_portion[:id]
				)
				CombiPlannerShoppingListPortion.where(id: p.id).update_all(
					planner_portion_wrapper_id: wrapper_portion[:id]
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
			if serving_addition(stock_group)
				stock_addition_hash = serving_addition(stock_group)
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

	def shopping_list_portions(shopping_list = nil)
		if shopping_list == nil && current_user && current_user.planner_shopping_list.present?
			shopping_list = current_user.planner_shopping_list
		elsif shopping_list == nil && !(current_user)
			return []
		elsif current_user && !current_user.planner_shopping_list.present?
			shopping_list = PlannerShoppingList.find_or_create_by(user_id: current_user.id)
		end

		planner_recipe_portions = []
		planner_portions_with_wrap = []
		if shopping_list.planner_recipes.length > 0
			all_planner_recipe_portions = shopping_list.planner_recipes.select{|pr| pr.date > Date.current - 6.hours && pr.date < Date.current + 7.day}.map{|pr| pr.planner_shopping_list_portions.reject{|p| p.combi_planner_shopping_list_portion_id != nil}.reject{|p| p.ingredient.name.downcase == 'water'}.reject{|p| p.checked == true && p.updated_at < Time.current - 1.day}}.flatten
			planner_recipe_portions = all_planner_recipe_portions.reject{|p|p.planner_portion_wrapper_id != nil}
			planner_portions_with_wrap = all_planner_recipe_portions.reject{|p|p.planner_portion_wrapper_id == nil}
		end

		combi_portions = []
		combi_portions_with_wrap = []
		if shopping_list.combi_planner_shopping_list_portions.length > 0
			all_combi_portions = shopping_list.combi_planner_shopping_list_portions.select{|c|c.date > Date.current - 6.hours && c.date < Date.current + 7.day}.reject{|cp| cp.checked == true && cp.updated_at < Time.current - 1.day}
			combi_portions = all_combi_portions.reject{|cp|cp.planner_portion_wrapper_id != nil}
			combi_portions_with_wrap = all_combi_portions.reject{|cp|cp.planner_portion_wrapper_id == nil}
		end

		portion_wrappers = []
		if shopping_list.planner_portion_wrappers.length > 0
			wrapped_portions = combi_portions_with_wrap + planner_portions_with_wrap
			portion_wrappers = wrapped_portions.map{|p|p.planner_portion_wrapper}
		end


		shopping_list_portions = combi_portions + planner_recipe_portions + portion_wrappers
		return shopping_list_portions.sort_by!{|p| p.ingredient.name}
	end

	def unchecked_portions
		return shopping_list_portions.count{|p|p.checked == false}
	end
	def checked_portions
		return shopping_list_portions.count{|p|p.checked == true}
	end

	def planner_portion_id_hash
		return Hashids.new(ENV['PLANNER_PORTIONS_SALT'])
	end
end
