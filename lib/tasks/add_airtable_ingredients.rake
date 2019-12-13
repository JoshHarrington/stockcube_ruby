require "#{Rails.root}/app/task_helpers/csv_hash_helper"
include CsvHashHelper

desc "Add ingredients from airtable csv"

task :add_airtable_ingredients => :environment do
	ingredient_hash = process_csv_to_hash("./db/airtable_csvs/Ingredients-Grid_view.csv")

	ingredient_hash.each do |row|
		content = row[1]
		Ingredient.find_or_create_by(
			name: content["name"]
		)
	end
end