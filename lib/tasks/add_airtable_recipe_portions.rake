require "#{Rails.root}/app/task_helpers/csv_hash_helper"
include CsvHashHelper

desc "Add recipe authors from airtable csv"

task :add_airtable_recipe_portions => :environment do
	# ingredient_hash = process_csv_to_hash("./db/airtable_csvs/Ingredients-Grid_view.csv")
	recipes_hash = process_csv_to_hash("./db/airtable_csvs/Recipes-Grid_view.csv")
	portions_hash = process_csv_to_hash("./db/airtable_csvs/Portions-Grid_view.csv")

	portions_hash.each do |row|
		content = row[1]

		recipe_title = recipes_hash.map{|k| if k[1]["id"] == content["recipes"]; k[1]; else nil; end}.compact.first["title"].strip.titleize
		recipe = Recipe.find_by(title: recipe_title)

		if content["unit"] && content["unit"] != nil && content["unit"].length > 0
			unit = Unit.find_by(name: content["unit"])
		else
			unit = Unit.find_by(name: "dash")
		end
		amount = content["amount"] && content["amount"] != nil && content["amount"].length > 0 ? content["amount"] : 1
		ingredient = Ingredient.find_by(name: content["ingredient"])

		portion = Portion.find_or_create_by(
			ingredient_id: ingredient.id,
			recipe_id: recipe.id,
			amount: amount,
			unit_id: unit.id
		)

		puts portion.ingredient.name.to_s + " - added to - " + recipe.title.to_s
	end
end
