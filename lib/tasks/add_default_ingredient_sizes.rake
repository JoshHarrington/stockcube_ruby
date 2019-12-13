require "#{Rails.root}/app/task_helpers/csv_hash_helper"
include CsvHashHelper

desc "Add recipe authors from airtable csv"

task :add_default_ingredient_sizes => :environment do

	default_ingredient_sizes_hash = process_csv_to_hash("./db/airtable_csvs/Default_ingredient_units-Grid_view.csv")

	default_ingredient_sizes_hash.each do |row|
		content = row[1]


		if content["join_to_units"] && content["join_to_units"] != nil && content["join_to_units"].length > 0
			unit = Unit.find_by(name: content["join_to_units"])
		else
			unit = Unit.find_by(name: "dash")
		end
		ingredient = Ingredient.find_by(name: content["ingredient"])
		amounts = []
		amounts << content["shopping_portion1"]
		amounts << content["shopping_portion2"]
		amounts << content["shopping_portion3"]
		amounts.each do |amount|
			next if amount == nil || amount.length < 1
			DefaultIngredientSize.find_or_create_by(
				ingredient_id: ingredient.id,
				unit_id: unit.id,
				amount: amount
			)
		end
		puts 'Default sizes added for ' + ingredient.name.to_s

	end
end
