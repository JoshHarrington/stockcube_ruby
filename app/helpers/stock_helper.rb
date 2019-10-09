module StockHelper
	include PlannerShoppingListHelper
	# if updating one or more ingredients (stock addition) - ingredient_id should be defined
	# if no ingredient_id defined then use all of current users stock to search for matching recipes

	def update_recipe_stock_matches_core(ingredient_ids = nil, user_id = nil, recipe_ids = nil)

		if user_id != nil
			user_id = user_id
		elsif current_user
			user_id = current_user[:id]
		else
			return
		end

		active_cupboard_ids = CupboardUser.where(user_id: user_id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard == nil && (cu.cupboard.setup == true || cu.cupboard.hidden == true) }.compact
		cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: active_cupboard_ids, hidden: false, planner_recipe_id: nil).where("use_by_date >= :date", date: Date.current - 2.days).map{ |s| s.ingredient_id }.uniq.compact

		filtered_ingredient_ids = [].push(ingredient_ids).uniq.flatten.compact
		filtered_recipe_ids = [].push(recipe_ids).uniq.flatten.compact

		search_recipes = []
		collected_recipes = []
		if filtered_recipe_ids.length > 0
			collected_recipes = Recipe.find(filtered_recipe_ids)
		elsif filtered_ingredient_ids.length > 0
			ingredient_names = Ingredient.find(filtered_ingredient_ids).map(&:name)
			search_recipes = Recipe.search(ingredient_names, operator: "or", fields: ["ingredient_names^100"]).results.uniq
		end
		if filtered_recipe_ids.length == 0 && filtered_ingredient_ids.length == 0
			collected_recipes = Recipe.all.uniq.reject{|r| !r.portions || r.portions.length == 0}
		end

		all_recipes = collected_recipes + search_recipes
		all_recipes.each do |recipe|
			recipe_stock_update(recipe, cupboard_stock_in_date_ingredient_ids, user_id)
		end
	end

	def	update_recipe_stock_matches(ingredient_ids = nil, user_id = nil, recipe_ids = nil)
		return unless current_user.user_recipe_stock_matches.order("updated_at desc").first.updated_at < 20.minutes.ago
		update_recipe_stock_matches_core(ingredient_ids, user_id, recipe_ids)

		flash[:info] = %Q[We've updated your <a href="/recipes">recipe list</a> based on your stock so you can see the quickest recipes to make]

	end

	def recipe_stock_update(recipe, cupboard_stock_in_date_ingredient_ids, user_id)
		recipe_ingredient_ids = recipe.portions.map(&:ingredient_id)
		num_ingredients_total = recipe_ingredient_ids.length.to_i
		recipe_stock_ingredient_matches = recipe_ingredient_ids & cupboard_stock_in_date_ingredient_ids
		num_stock_ingredients = recipe_stock_ingredient_matches.length.to_i
		ingredient_stock_match_decimal = num_stock_ingredients.to_f / num_ingredients_total.to_f
		num_needed_ingredients = num_ingredients_total - num_stock_ingredients

		UserRecipeStockMatch.find_or_create_by(
			recipe_id: recipe[:id],
			user_id: user_id
		).update_attributes(
			ingredient_stock_match_decimal: ingredient_stock_match_decimal,
			num_ingredients_total: num_ingredients_total,
			num_stock_ingredients: num_stock_ingredients,
			num_needed_ingredients: num_needed_ingredients
		)
	end

	def toggle_stock_on_portion_check(params, processing_type)
		if params.has_key?(:gen_id) && PlannerShoppingList.find_by(gen_id: params[:gen_id])
			shopping_list = PlannerShoppingList.find_by(gen_id: params[:gen_id])
		elsif current_user
			shopping_list = current_user.planner_shopping_list
		else
			return
		end

		return unless params.has_key?(:shopping_list_portion_id) && params.has_key?(:portion_type)
		shopping_list.update_attributes(
			ready: false
		)

		if params[:portion_type] == 'combi_portion'
			combi_portion = shopping_list.combi_planner_shopping_list_portions.find(planner_portion_id_hash.decode(params[:shopping_list_portion_id])).first
		elsif params[:portion_type] == 'individual_portion'
			individual_portion = shopping_list.planner_shopping_list_portions.find(planner_portion_id_hash.decode(params[:shopping_list_portion_id])).first
		elsif params[:portion_type] == 'wrapper_portion'
			wrapper_portion = shopping_list.planner_portion_wrappers.find(planner_portion_id_hash.decode(params[:shopping_list_portion_id])).first
		end

		recipe_ids = []
		ingredient_ids = []

		if wrapper_portion.present?
			if wrapper_portion.planner_shopping_list_portion.planner_recipe.recipe_id
				recipe_ids.push(wrapper_portion.planner_shopping_list_portion.planner_recipe.recipe_id)
			else
				ingredient_ids.push(wrapper_portion.ingredient_id)
			end
			convert_portions_to_stock(wrapper_portion.planner_shopping_list_portion, processing_type, shopping_list.user_id)
			if processing_type && processing_type == 'add_portion'
				wrapper_portion.update_attributes(checked: true)
				wrapper_portion.planner_shopping_list_portion.update_attributes(checked: true)
			elsif processing_type && processing_type == 'remove_portion'
				wrapper_portion.update_attributes(checked: false)
				wrapper_portion.planner_shopping_list_portion.update_attributes(checked: false)
			end
		end
		if combi_portion.present?
			combi_portion.planner_shopping_list_portions.each do |portion|
				if portion.planner_recipe.recipe_id
					recipe_ids.push(portion.planner_recipe.recipe_id)
				else
					ingredient_ids.push(combi_portion.ingredient_id)
				end
				if processing_type && processing_type == 'add_portion'
					portion.update_attributes(checked: true)
				elsif processing_type && processing_type == 'remove_portion'
					portion.update_attributes(checked: false)
				end
			end
			convert_portions_to_stock(combi_portion.planner_shopping_list_portions, processing_type, shopping_list.user_id)
			if processing_type && processing_type == 'add_portion'
				combi_portion.update_attributes(checked: true)
			elsif processing_type && processing_type == 'remove_portion'
				combi_portion.update_attributes(checked: false)
			end
		end
		if individual_portion.present?
			if individual_portion.planner_recipe.recipe_id
				recipe_ids.push(individual_portion.planner_recipe.recipe_id)
			else
				ingredient_ids.push(individual_portion.ingredient_id)
			end
			convert_portions_to_stock(individual_portion, processing_type, shopping_list.user_id)
			if processing_type && processing_type == 'add_portion'
				individual_portion.update_attributes(checked: true)
			elsif processing_type && processing_type == 'remove_portion'
				individual_portion.update_attributes(checked: false)
			end

			if recipe_ids.length > 0
				update_recipe_stock_matches_core(nil, shopping_list.user_id, recipe_ids)
			elsif ingredient_ids.length > 0
				update_recipe_stock_matches_core(ingredient_ids, shopping_list.user_id)
			end
		end

		shopping_list.update_attributes(
			ready: true
		)
	end

	def convert_portions_to_stock(portions, processing_type, user_id = nil)
		portions_array = [].push(portions).flatten
		if current_user
			shopping_list_user = current_user
		elsif user_id != nil
			shopping_list_user = User.find(user_id)
		else
			return
		end

		cupboard_id = shopping_list_user.cupboard_users.where(accepted: true).select{|cu| cu.cupboard.setup == false && cu.cupboard.hidden == false }.map{|cu| cu.cupboard }.sort_by{|c| c.updated_at}.first.id
		portions_array.each do |portion|
			if portion.class.name == "PlannerShoppingListPortion"

				recipe_stock = Stock.find_by(
					ingredient_id: portion.ingredient_id,
					unit_id: portion.unit_id,
					planner_shopping_list_portion_id: portion.id
				)
				if recipe_stock != nil
					recipe_stock.update_attributes(
						amount: portion.amount,
						planner_recipe_id: portion.planner_recipe_id,
						use_by_date: Date.current + 2.weeks,
						cupboard_id: cupboard_id,
						always_available: false
					)
				else
					recipe_stock = Stock.create(
						ingredient_id: portion.ingredient_id,
						amount: portion.amount,
						planner_recipe_id: portion.planner_recipe_id,
						unit_id: portion.unit_id,
						use_by_date: Date.current + 2.weeks,
						cupboard_id: cupboard_id,
						always_available: false,
						planner_shopping_list_portion_id: portion.id
					)
					shopping_list_user.stocks << recipe_stock
				end

				if processing_type && (processing_type == 'remove_portion' || processing_type == 'add_portion')
					check_type = processing_type == 'remove_portion' ? true : false
					if portion.planner_portion_wrapper != nil
						if portion.planner_portion_wrapper.checked != check_type
							portion.planner_portion_wrapper.update_attributes(checked: check_type)
						end
						## find diff between portion size and wrapper size
						## create new stock with this leftover size
						## add planner_portion_wrapper_id to stock
						wrapper_stock_diff = serving_difference([portion.planner_portion_wrapper, portion])
						if wrapper_stock_diff != false
							wrapper_stock = Stock.find_by(
								ingredient_id: portion.ingredient_id,
								unit_id: wrapper_stock_diff[:unit_id],
								planner_portion_wrapper_id: portion.planner_portion_wrapper_id
							)
							if wrapper_stock != nil
								wrapper_stock.update_attributes(
									amount: wrapper_stock_diff[:amount],
									use_by_date: Date.current + 2.weeks,
									cupboard_id: cupboard_id,
									always_available: false
								)
							else
								wrapper_stock = Stock.create(
									ingredient_id: portion.ingredient_id,
									amount: wrapper_stock_diff[:amount],
									unit_id: wrapper_stock_diff[:unit_id],
									use_by_date: Date.current + 2.weeks,
									cupboard_id: cupboard_id,
									always_available: false,
									planner_portion_wrapper_id: portion.planner_portion_wrapper_id
								)
								shopping_list_user.stocks << wrapper_stock
							end
							stock_hidden = processing_type == 'add_portion' ? false : true
							wrapper_stock.update_attributes(hidden: stock_hidden)
						end
					elsif portion.combi_planner_shopping_list_portion != nil && portion.combi_planner_shopping_list_portion.checked != check_type
						portion.combi_planner_shopping_list_portion.update_attributes(checked: check_type)
					elsif portion.class.name == "PlannerShoppingListPortion" && portion.checked != check_type
						portion.update_attributes(checked: check_type)
					end
					stock_hidden = processing_type == 'add_portion' ? false : true
					recipe_stock.update_attributes(hidden: stock_hidden)
				end
			end


		end

	end

end

