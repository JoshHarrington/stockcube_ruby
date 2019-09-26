require "#{Rails.root}/app/task_helpers/csv_hash_helper"
include CsvHashHelper

desc "Add recipe authors from airtable csv"

task :add_airtable_recipe_authors => :environment do
	recipes_hash = process_csv_to_hash("./db/airtable_csvs/Recipes-Grid_view.csv")
	authors_hash = process_csv_to_hash("./db/airtable_csvs/Authors-Grid_view.csv")

	authors_hash.each do |row|
		content = row[1]
		author = Author.find_or_create_by(
			name: content["name"],
			link: content["link"]
		)
		puts author.name.to_s + " - created"
		if content["recipes"].class == String
			content["recipes"].split(",").each do |airtable_r_id|
				recipe_title = recipes_hash.map{|k| if k[1]["id"] == airtable_r_id; k[1]; else nil; end}.compact.first["title"].strip.titleize
				recipe = Recipe.find_by(title: recipe_title)
				puts "associating " + recipe.title + " to " + author.name

				RecipeAuthor.find_or_create_by(
					recipe_id: recipe.id,
					author_id: author.id
				)
			end
		end
	end
end