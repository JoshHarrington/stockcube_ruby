namespace :units_fix do
	desc "Ensure all units unit_numbers are equal to ids before removing unit_numbers"
	task :update_units_to_correct_unit_number => :environment do
		if Unit.all[-2].unit_number != Unit.all[-2].id
			Unit.all.each do |unit|
				Stock.where(unit_id: unit.unit_number).each do |stock|
					stock.update_attributes(
						unit_id: unit.id
					)
				end
				Portion.where(unit_number: unit.unit_number).each do |portion|
					portion.update_attributes(
						unit_number: unit.id
					)
				end
				unit.update_attributes(
					unit_number: unit.id
				)
			end
		end

		Unit.where(name: nil).delete_all

	end
end