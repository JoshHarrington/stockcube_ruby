## copy of app/helpers/stock_helper

module TaskStockHelper

	def	update_recipe_stock_matches_for_user(user_id)
		two_days_ago = Date.current - 2.days
		active_cupboard_ids = CupboardUser.where(user_id: user_id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard == nil && (cu.cupboard.setup == true || cu.cupboard.hidden == true) }.compact
		cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: active_cupboard_ids, hidden: false).where("use_by_date >= :date", date: two_days_ago).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact

		Recipe.all.uniq.each do |recipe|
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

	end

	def update_recipe_stock_matches_all_users
		User.where(activated: true).each do |user|
			update_recipe_stock_matches_for_user(user[:id])
		end
	end

end
