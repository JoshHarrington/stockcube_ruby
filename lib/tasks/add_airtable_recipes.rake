require "#{Rails.root}/app/task_helpers/csv_hash_helper"
include CsvHashHelper

desc "Add recipe from airtable csv"

task :add_airtable_recipes => :environment do
	recipe_hash = process_csv_to_hash("./db/airtable_csvs/Recipes-Grid_view.csv")

	recipe_hash.each do |row|
		content = row[1]
		Recipe.find_or_create_by(
			title: content["title"].strip.titleize,
			link: content["link"] || nil
		)
	end
end