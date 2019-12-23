desc "All users need water in their cupboards to make searching accurate"

task :add_water_for_all_users => :environment do
	water_id = Ingredient.where(name: "Water").map(&:id).first
	liter_id = Unit.where(name: "Liter").map(&:id).first
	User.all.each do |user|
		# user = User.find(4)
		puts "Add Water for " + user.name.to_s
		cupboard_ids = CupboardUser.where(user_id: user[:id], accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard.setup == true || cu.cupboard.hidden == true }.compact
		if cupboard_ids.length == 0
			puts "No cupboards found"
			new_cupboard = Cupboard.create(
				hidden: false,
				setup: false,
				location: "Your first cupboard"
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
			puts "Cupboard found: " + Cupboard.find(new_cupboard_id).location.to_s
		end
		# next if Stock.where(ingredient_id: water_id, hidden: true, cupboard_id: cupboard_ids).length != 0
		Stock.find_or_create_by(
			hidden: false,
			always_available: true,
			ingredient_id: water_id,
			cupboard_id: new_cupboard_id,
			unit_id: liter_id
		).update_attributes(
			amount: 9223372036854775807,
			use_by_date: Date.current + 100.years
		)
		puts "Water added"
	end
end