desc "All users need water in their cupboards to make searching accurate"

task :add_water_for_all_users => :environment do
	water_id = Ingredient.where(name: "Water").map(&:id).first
	liter_id = Unit.where(name: "Liter").map(&:id).first
	User.all.each do |user|
		# user = User.find(4)
		cupboard_ids = user.cupboards.where(hidden: false, setup: false).map(&:id)
		if cupboard_ids.length == 0
			new_cupboard = Cupboard.create(
				hidden: false,
				setup: false,
				location: "Kitchen"
			)
			new_cupboard_id = new_cupboard[:id]
			CupboardUser.create(
				cupboard_id: new_cupboard_id,
				user_id: user[:id],
				owner: true,
				accepted: true
			)
		else
			new_cupboard_id = cupboard_ids.first
		end
		next if Stock.where(ingredient_id: water_id, hidden: true, cupboard_id: cupboard_ids).length != 0
		Stock.create(
			hidden: true,
			ingredient_id: water_id,
			amount: 9223372036854775807,
			unit_id: liter_id,
			cupboard_id: new_cupboard_id,
			use_by_date: Date.current + 100.years
		)
	end
end