desc "Find demo user, if it doesn't exist create it, add cupboards and stock"
task :find_user_add_random_stock => :environment do
	set_user = User.find(13)

	c1 = Cupboard.create(location: "Fridge Door")
	c2 = Cupboard.create(location: "Fridge Bottom Drawer")
	c3 = Cupboard.create(location: "Fridge Top Shelf")
	c4 = Cupboard.create(location: "Cupboard by the Oven")

	[c1, c2, c3, c4].each do |cupboard|
		CupboardUser.create(
			cupboard_id: cupboard.id,
			user_id: set_user.id,
			owner: true,
			accepted: true
		)
	end

	ingredient_picks = Ingredient.where(searchable: true).sample(15)

	ingredient_picks.each do |ingredient|

		cupboard_pick_id = CupboardUser.where(user_id: set_user.id).sample.cupboard_id

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
end


