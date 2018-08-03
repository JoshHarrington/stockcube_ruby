namespace :add_fav_stock_if_none do
  desc "Check if user already has fav stock, if none then create 6 basics"
	task :add_fav_stock => :environment do
		User.all.each do |user|
			if user.fav_stock.length == 0
				### setup user with some fav stock for quick add
				@tomatoe_id = Ingredient.where(name: "Tomatoes").first.id
				@egg_id = Ingredient.where(name: "Egg").first.id
				@bread_id = Ingredient.where(name: "Bread (White)").first.id  ## need to add (to production)
				@milk_id = Ingredient.where(name: "Milk").first.id
				@onion_id = Ingredient.where(name: "Onion").first.id
				@cheese_id = Ingredient.where(name: "Cheese (Cheddar)").first.id

				@each_unit_id = Unit.where(name: "Each").first.id
				@loaf_unit_id = Unit.where(name: "Loaf").first.id 	## need to add (to production)
				@pint_unit_id = Unit.where(name: "Pint").first.id
				@gram_unit_id = Unit.where(name: "Gram").first.id

				UserFavStock.create (
					ingredient_id: @tomatoe_id,
					stock_amount: 4,
					unit_id: @each_unit_id,
					user_id: user.id,
					standard_use_by_limit: 5
				)
				UserFavStock.create (
					ingredient_id: @egg_id,
					stock_amount: 6,
					unit_id: @each_unit_id,
					user_id: user.id,
					standard_use_by_limit: 9
				)
				UserFavStock.create (
					ingredient_id: @bread_id,
					stock_amount: 1,
					unit_id: @loaf_unit_id,
					user_id: user.id,
					standard_use_by_limit: 4
				)
				UserFavStock.create (
					ingredient_id: @milk_id,
					stock_amount: 1,
					unit_id: @pint_unit_id,
					user_id: user.id,
					standard_use_by_limit: 8
				)
				UserFavStock.create (
					ingredient_id: @onion_id,
					stock_amount: 3,
					unit_id: @each_unit_id,
					user_id: user.id,
					standard_use_by_limit: 14
				)
				UserFavStock.create (
					ingredient_id: @cheese_id,
					stock_amount: 350,
					unit_id: @gram_unit_id,
					user_id: user.id,
					standard_use_by_limit: 28
				)
			end
		end
	end
end