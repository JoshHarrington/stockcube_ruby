require "#{Rails.root}/app/task_helpers/csv_hash_helper"
include CsvHashHelper

desc "Add recipe steps from airtable csv"

task :add_airtable_recipe_steps => :environment do
	recipes_hash = process_csv_to_hash("./db/airtable_csvs/Recipes-Grid_view.csv")
	recipe_steps_hash = process_csv_to_hash("./db/airtable_csvs/Recipe_steps-Grid_view.csv")

	recipe_steps_hash.each do |row|
		content = row[1]
		recipe_title = recipes_hash.map{|k| if k[1]["id"] == content["recipes"]; k[1]; else nil; end}.compact.first["title"].strip.titleize
		recipe = Recipe.find_by(title: recipe_title)
		RecipeStep.find_or_create_by(
			number: content["step_number"].to_i + 1,
			recipe_id: recipe.id,
			content: content["step_content"]
		)
	end
end