module StockHelper
	def recipe_stock_matches_update(user_id)
		active_cupboard_ids = CupboardUser.where(user_id: user_id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard == nil && (cu.cupboard.setup == true || cu.cupboard.hidden == true) }.compact

		all_cupboard_ids = CupboardUser.where(user_id: user_id, accepted: true).map(&:cupboard_id)
		stock_updated_last_hour_num = Stock.where(cupboard_id: all_cupboard_ids).where("updated_at >= :last_hour", last_hour: Time.current - 1.hour).length

		if stock_updated_last_hour_num > 0

			cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: active_cupboard_ids, hidden: false).where("use_by_date >= :date", date: Date.current - 2.days).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact

			Recipe.all.each_with_index do |recipe, i|

				recipe_ingredient_ids = recipe.ingredients.map(&:id)
				unless recipe_ingredient_ids == nil
					num_ingredients_total = recipe_ingredient_ids.length.to_i
					recipe_stock_ingredient_matches = recipe_ingredient_ids & cupboard_stock_in_date_ingredient_ids
					num_stock_ingredients = recipe_stock_ingredient_matches.length.to_i
					ingredient_stock_match_decimal = num_stock_ingredients.to_f / num_ingredients_total.to_f
					num_needed_ingredients = num_ingredients_total - num_stock_ingredients

					UserRecipeStockMatch.find_or_create_by(
						recipe_id: recipe.id,
						user_id: user_id
					).update_attributes(
						ingredient_stock_match_decimal: ingredient_stock_match_decimal,
						num_ingredients_total: num_ingredients_total,
						num_stock_ingredients: num_stock_ingredients,
						num_needed_ingredients: num_needed_ingredients,
					)
				end
			end
		end
	end
end
