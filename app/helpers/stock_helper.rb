module StockHelper
	# if updating one ingredient (stock addition)

	def	update_recipe_stock_from_stock_change(ingredient_id)
		two_days_ago = Date.current - 2.days
		user_id = current_user[:id]
		ingredient_name = Ingredient.find(ingredient_id)[:name]
		recipes = Recipe.search(ingredient_name, fields: ["ingredient_names^100"]).results.uniq
		active_cupboard_ids = CupboardUser.where(user_id: user_id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard == nil && (cu.cupboard.setup == true || cu.cupboard.hidden == true) }.compact
		cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: active_cupboard_ids, hidden: false).where("use_by_date >= :date", date: two_days_ago).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact

		recipes.each do |recipe|
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

		flash[:info] = %Q[We've updated your <a href="/recipes">recipe list</a> based on your stock<br/>so you can see the quickest recipes to make]

	end


end

