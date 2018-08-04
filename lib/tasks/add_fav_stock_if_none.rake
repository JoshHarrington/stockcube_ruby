namespace :add_fav_stock_if_none do
  desc "Check if user already has fav stock, if none then create 6 basics"
	task :add_fav_stock => :environment do
		User.all.each do |user|
			if UserFavStock.where(user_id: user.id).length == 0
				### setup user with some fav stock for quick add
				@tomatoe_id = Ingredient.find_or_create_by(name: "Tomatoes").id
				@egg_id = Ingredient.find_or_create_by(name: "Egg").id
				@bread_id = Ingredient.find_or_create_by(name: "Bread (White)").id
				@milk_id = Ingredient.find_or_create_by(name: "Milk").id
				@onion_id = Ingredient.find_or_create_by(name: "Onion").id
				@cheese_id = Ingredient.find_or_create_by(name: "Cheese (Cheddar)").id

				@each_unit_id = Unit.find_or_create_by(name: "Each").id
				@loaf_unit_id = Unit.find_or_create_by(name: "Loaf").id
				@pint_unit_id = Unit.find_or_create_by(name: "Pint").id
				@gram_unit_id = Unit.find_or_create_by(name: "Gram").id

				UserFavStock.create(
					ingredient_id: @tomatoe_id,
					stock_amount: 4,
					unit_id: @each_unit_id,
					user_id: user.id,
					standard_use_by_limit: 5
				)
				UserFavStock.create(
					ingredient_id: @egg_id,
					stock_amount: 6,
					unit_id: @each_unit_id,
					user_id: user.id,
					standard_use_by_limit: 9
				)
				UserFavStock.create(
					ingredient_id: @bread_id,
					stock_amount: 1,
					unit_id: @loaf_unit_id,
					user_id: user.id,
					standard_use_by_limit: 4
				)
				UserFavStock.create(
					ingredient_id: @milk_id,
					stock_amount: 1,
					unit_id: @pint_unit_id,
					user_id: user.id,
					standard_use_by_limit: 8
				)
				UserFavStock.create(
					ingredient_id: @onion_id,
					stock_amount: 3,
					unit_id: @each_unit_id,
					user_id: user.id,
					standard_use_by_limit: 14
				)
				UserFavStock.create(
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