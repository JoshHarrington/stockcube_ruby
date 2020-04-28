require "#{Rails.root}/app/task_helpers/shopping_lists_helper"
include TaskShoppingListsHelper

namespace :demo_user do
  desc "Find demo user, if it doesn't exist create it, add cupboards and stock"
	task :find_or_create_demo_user => :environment do
		if User.exists?(demo: true)
			demo_user = User.where(demo: true).first
			demo_user.cupboards.destroy_all
			demo_user.shopping_lists.destroy_all
			demo_user.favourites.delete_all
		else
			demo_user = User.create(name:  "Demo User",
				email: ENV['DEMO_EMAIL'],
				password:              ENV['DEMO_PASSWORD'],
				password_confirmation: ENV['DEMO_PASSWORD'],
				admin: false,
				demo: true,
				activated: true,
				activated_at: Time.zone.now)
		end

		c1 = Cupboard.create(location: "Fridge Door")
		c2 = Cupboard.create(location: "Fridge Bottom Drawer")
		c3 = Cupboard.create(location: "Fridge Top Shelf")
		c4 = Cupboard.create(location: "Cupboard by the Oven")

		[c1, c2, c3, c4].each do |cupboard|
			 CupboardUser.create(
				cupboard_id: cupboard.id,
				user_id: demo_user.id,
				owner: true,
				accepted: true
			 )
		end

		ingredient_picks = Ingredient.where(searchable: true).sample(15)

		ingredient_picks.each do |ingredient|

			cupboard_pick_id = CupboardUser.where(user_id: demo_user.id).sample.cupboard_id

			extra_days_random = [*5..30].sample

			test_use_by_date = Date.today + extra_days_random.days

			random_amount = [*1..17].sample

			stock = Stock.create(
				amount: random_amount,
				use_by_date: test_use_by_date,
				unit_id: ingredient.unit_id,
				cupboard_id: cupboard_pick_id,
				ingredient_id: ingredient.id
			)

		end

		recipe_fav_picks = Recipe.all.sample(10)

		demo_user.favourites << recipe_fav_picks

		recipe_shopping_list_picks = Recipe.all.sample(3)

		new_shopping_list = ShoppingList.create(user_id: demo_user.id)

		new_shopping_list.recipes << recipe_shopping_list_picks

		recipe_shopping_list_picks.each do |recipe|
			TaskShoppingListsHelper.shopping_list_portions_set_from_recipes(recipe[:id], nil, demo_user[:id], nil)
		end

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
		@gram_unit_id = Unit.where(name: "gram").first.id

		UserFavStock.create(
			ingredient_id: @tomatoe_id,
			stock_amount: 4,
			unit_id: @each_unit_id,
			user_id: demo_user.id,
			standard_use_by_limit: 5
		)
		UserFavStock.create(
			ingredient_id: @egg_id,
			stock_amount: 6,
			unit_id: @each_unit_id,
			user_id: demo_user.id,
			standard_use_by_limit: 9
		)
		UserFavStock.create(
			ingredient_id: @bread_id,
			stock_amount: 1,
			unit_id: @loaf_unit_id,
			user_id: demo_user.id,
			standard_use_by_limit: 4
		)
		UserFavStock.create(
			ingredient_id: @milk_id,
			stock_amount: 1,
			unit_id: @pint_unit_id,
			user_id: demo_user.id,
			standard_use_by_limit: 8
		)
		UserFavStock.create(
			ingredient_id: @onion_id,
			stock_amount: 3,
			unit_id: @each_unit_id,
			user_id: demo_user.id,
			standard_use_by_limit: 14
		)
		UserFavStock.create(
			ingredient_id: @cheese_id,
			stock_amount: 350,
			unit_id: @gram_unit_id,
			user_id: demo_user.id,
			standard_use_by_limit: 28
		)



	end
end



