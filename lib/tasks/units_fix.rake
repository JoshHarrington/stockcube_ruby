namespace :units_fix do
	desc "Ensure all units unit_numbers are equal to ids before removing unit_numbers"
	task :update_units_to_correct_unit_number => :environment do
		if Unit.all[-2].unit_number != Unit.all[-2].id
			Unit.all.each do |unit|
				unit.update_attributes(
					unit_number: unit.id
				)
			end
		end

		Unit.where(name: nil).delete_all

	end
end