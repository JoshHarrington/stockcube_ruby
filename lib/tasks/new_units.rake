namespace :new_units do
	desc "Find or add new units"
	task :find_or_create_new_units => :environment do
		Unit.find_or_create_by(name: "Loaf", short_name: "loaf")
	end
end
