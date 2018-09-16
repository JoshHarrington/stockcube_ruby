desc "setup recipe stock matches if stock exists, otherwise set all columns to 0"
task :find_user_add_recipe_stock_matches => :environment do
	# set_user = User.find(4)
	# recipe = Recipe.first

	User.all.each do |set_user|

		cupboard_ids = CupboardUser.where(user_id: set_user[:id], accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard.setup == true || cu.cupboard.hidden == true }.compact
		cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: cupboard_ids, hidden: false).where("use_by_date >= :date", date: Date.current - 2.days).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact

		Recipe.all.each do |recipe|

			recipe_ingredient_ids = recipe.ingredients.map(&:id)
			unless recipe_ingredient_ids == nil
				num_ingredients_total = recipe_ingredient_ids.length.to_i
				recipe_stock_ingredient_matches = recipe_ingredient_ids & cupboard_stock_in_date_ingredient_ids
				num_stock_ingredients = recipe_stock_ingredient_matches.length.to_i
				ingredient_stock_match_decimal = num_stock_ingredients.to_f / num_ingredients_total.to_f
				num_needed_ingredients = num_ingredients_total - num_stock_ingredients

				UserRecipeStockMatch.find_or_create_by(
					recipe_id: recipe[:id],
					user_id: set_user[:id],
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