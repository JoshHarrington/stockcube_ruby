desc "Remove all empty setup cupboards"

task :remove_old_setup_cupboards => :environment do

	user = User.find(4)
	# User.all.each do |user|

		setup_cupboards = CupboardUser.where(user_id: user[:id], accepted: true).map{|cu| cu.cupboard if cu.cupboard.setup == true && cu.cupboard.hidden == false }.compact
		setup_cupboards.map{|sc| sc.delete if sc.empty?}
		# setup_cupboards.each do |sc|
		# 	sc.stocks.map{|s| s.id if s.use_by_date <= (Time.now - 4.days)}.compact
		# end
		setup_cupboards.map{|sc| sc.delete if sc.stocks.map{|s| s.id if s.use_by_date <= (Time.now - 4.days)}.compact.empty? }



		if cupboard_ids.length == 0
			puts "No cupboards found"
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