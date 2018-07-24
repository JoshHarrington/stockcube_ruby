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
				email: "demo@stockcub.es",
				password:              "password",
				password_confirmation: "password",
				admin: false,
				demo: true,
				activated: true,
				activated_at: Time.zone.now)
		end

		c1 = Cupboard.create(location: "Fridge Door")
		c2 = Cupboard.create(location: "Fridge Bottom Drawer")
		c3 = Cupboard.create(location: "Fridge Top Shelf")
		c4 = Cupboard.create(location: "Cupboard by the Oven")

		demo_user.cupboards << [c1, c2, c3, c4]

		ingredient_picks = Ingredient.where(searchable: true).sample(15)

		ingredient_picks.each do |ingredient|

			cupboard_pick = demo_user.cupboards.sample

			extra_days_random = [*5..30].sample

			test_use_by_date = Date.today + extra_days_random.days

			random_amount = [*1..17].sample

			stock = Stock.create(
				amount: random_amount,
				use_by_date: test_use_by_date,
				unit_number: ingredient.unit.unit_number,
				cupboard_id: cupboard_pick.id,
				ingredient_id: ingredient.id
			)

		end

		recipe_fav_picks = Recipe.all.sample(10)

		demo_user.favourites << recipe_fav_picks

		recipe_shopping_list_picks = Recipe.all.sample(3)

		new_shopping_list = ShoppingList.create(user_id: demo_user.id)

		new_shopping_list.recipes << recipe_shopping_list_picks

		recipe_shopping_list_picks.each do |recipe|
			recipe.portions.each do |portion|
				shopping_list_portion = ShoppingListPortion.create(shopping_list_id: new_shopping_list.id, recipe_number: recipe.id, portion_amount: portion.amount, ingredient_id: portion.ingredient_id, unit_number: portion.unit_number)
			end
		end



	end
end



