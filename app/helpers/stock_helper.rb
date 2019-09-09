module StockHelper
	# if updating one or more ingredients (stock addition) - ingredient_id should be defined
	# if no ingredient_id defined then use all of current users stock to search for matching recipes


	def update_recipe_stock_matches_core(ingredient_id = nil, user_id = nil, recipe_id = nil)
		two_days_ago = Date.current - 2.days
		if user_id != nil
			user_id = user_id
		elsif current_user
			user_id = current_user[:id]
		end

		active_cupboard_ids = CupboardUser.where(user_id: user_id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard == nil && (cu.cupboard.setup == true || cu.cupboard.hidden == true) }.compact
		cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: active_cupboard_ids, hidden: false, planner_recipe_id: nil).where("use_by_date >= :date", date: two_days_ago).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact

		if ingredient_id.class == Integer
			ingredient_name = Ingredient.find(ingredient_id)[:name]
			recipes = Recipe.search(ingredient_name, fields: ["ingredient_names^100"]).results.uniq
		elsif ingredient_id.class == Array
			ingredient_name = Ingredient.find(ingredient_id.uniq).map(&:name)
			recipes = Recipe.search(ingredient_name, operator: "or", fields: ["ingredient_names^100"]).results.uniq
		elsif recipe_id == nil
			recipes = Recipe.all.uniq
		end

		if recipe_id != nil
			recipe = Recipe.find(recipe_id)
			recipe_stock_update(recipe, cupboard_stock_in_date_ingredient_ids, user_id)
		else
			recipes.each do |recipe|
				recipe_stock_update(recipe, cupboard_stock_in_date_ingredient_ids, user_id)
			end
		end
	end

	def	update_recipe_stock_matches(ingredient_id = nil, user_id = nil, recipe_id = nil)
		return unless current_user.user_recipe_stock_matches.order("updated_at desc").first.updated_at < 20.minutes.ago
		update_recipe_stock_matches_core(ingredient_id, user_id, recipe_id)

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

	def add_individual_portion_as_stock(portion)

		cupboard_id = current_user.cupboard_users.where(accepted: true).select{|cu| cu.cupboard.setup == false && cu.cupboard.hidden == false }.map{|cu| cu.cupboard }.sort_by{|c| c.updated_at}.first.id

		recipe_stock = Stock.create(
			ingredient_id: portion.ingredient_id,
			amount: portion.amount,
			planner_recipe_id: portion.planner_recipe_id,
			unit_id: portion.unit_id,
			use_by_date: Date.current + 2.weeks,
			cupboard_id: cupboard_id,
			hidden: false,
			always_available: false
		)
		current_user.stocks << recipe_stock

	end

end

