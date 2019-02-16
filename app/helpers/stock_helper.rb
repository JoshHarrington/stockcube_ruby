module StockHelper
	def user_stock_update(user_id, recipe_id, cupboard_stock_in_date_ingredient_ids, recipe_ingredient_ids, waste_saving_rating)
		num_ingredients_total = recipe_ingredient_ids.length.to_i
		recipe_stock_ingredient_matches = recipe_ingredient_ids & cupboard_stock_in_date_ingredient_ids
		num_stock_ingredients = recipe_stock_ingredient_matches.length.to_i
		ingredient_stock_match_decimal = num_stock_ingredients.to_f / num_ingredients_total.to_f
		num_needed_ingredients = num_ingredients_total - num_stock_ingredients

		UserRecipeStockMatch.find_or_create_by(
			recipe_id: recipe_id,
			user_id: user_id
		).update_attributes(
			ingredient_stock_match_decimal: ingredient_stock_match_decimal,
			num_ingredients_total: num_ingredients_total,
			num_stock_ingredients: num_stock_ingredients,
			num_needed_ingredients: num_needed_ingredients,
			waste_saving_rating: waste_saving_rating
		)
	end

	def recipe_stock_matches_update(user_id = nil, recipe_id = nil)

		two_days_ago = Date.current - 2.days
		four_days_ahead = Date.current + 4.days

		if user_id == nil && recipe_id != nil
			# updating all user stock matches for one recipe
			recipe = Recipe.find(recipe_id)
			recipe_ingredient_ids = recipe.ingredients.map(&:id).uniq

			User.where(activated: true).each do |user|
				active_cupboard_ids = CupboardUser.where(user_id: user[:id], accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard == nil && (cu.cupboard.setup == true || cu.cupboard.hidden == true) }.compact
				cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: active_cupboard_ids, hidden: false).where("use_by_date >= :date", date: two_days_ago).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact

				num_ingredients_in_recipe = recipe_ingredient_ids.length
				cupboard_stock_out_of_date_soon_ingredient_ids = Stock.where(cupboard_id: active_cupboard_ids, hidden: false).where(:use_by_date => two_days_ago..four_days_ahead).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact
				num_ingredients_in_stock_in_ingredient_list_going_out_of_date_soon = recipe_ingredient_ids.select {|i_id| cupboard_stock_out_of_date_soon_ingredient_ids.include? i_id }.length
				waste_saving_rating = (num_ingredients_in_stock_in_ingredient_list_going_out_of_date_soon.to_f / num_ingredients_in_recipe.to_f).to_f

				user_stock_update(user[:id], recipe_id, cupboard_stock_in_date_ingredient_ids, recipe_ingredient_ids, waste_saving_rating)
			end
		elsif user_id != nil && (!recipe_id || recipe_id == nil)
			# updating all user stock matches for one user
			active_cupboard_ids = CupboardUser.where(user_id: user_id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard == nil && (cu.cupboard.setup == true || cu.cupboard.hidden == true) }.compact
			cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: active_cupboard_ids, hidden: false).where("use_by_date >= :date", date: two_days_ago).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact

			Recipe.where(live: true, public: true).each do |recipe|
				user = User.find(user_id)
				recipe_ingredient_ids = recipe.ingredients.map(&:id).uniq

				num_ingredients_in_recipe = recipe_ingredient_ids.length
				cupboard_stock_out_of_date_soon_ingredient_ids = Stock.where(cupboard_id: active_cupboard_ids, hidden: false).where(:use_by_date => two_days_ago..four_days_ahead).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact
				num_ingredients_in_stock_in_ingredient_list_going_out_of_date_soon = recipe_ingredient_ids.select {|i_id| cupboard_stock_out_of_date_soon_ingredient_ids.include? i_id }.length
				waste_saving_rating = (num_ingredients_in_stock_in_ingredient_list_going_out_of_date_soon.to_f / num_ingredients_in_recipe.to_f).to_f
				user_stock_update(user_id, recipe[:id], cupboard_stock_in_date_ingredient_ids, recipe_ingredient_ids, waste_saving_rating)
			end
		end

	end
end
