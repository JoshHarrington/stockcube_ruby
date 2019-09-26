desc "Add data from airtable csvs"

task :add_airtable_data => :environment do
	puts "Clear old database ingredient and recipe content"
	Rake::Task["clear_old_db"].invoke

	puts "Add units data"
	Rake::Task["add_airtable_units"].invoke

	puts "Add ingredient data"
	Rake::Task["add_airtable_ingredients"].invoke

	puts "Add recipe data"
	Rake::Task["add_airtable_recipes"].invoke

	puts "Add recipe step data"
	Rake::Task["add_airtable_recipe_steps"].invoke

	puts "Add recipe author data"
	Rake::Task["add_airtable_recipe_authors"].invoke

	puts "Add recipe portion data"
	Rake::Task["add_airtable_recipe_portions"].invoke

	puts "Add default ingredient sizes data"
	Rake::Task["add_default_ingredient_sizes"].invoke

	puts "Reindex recipes and ingredients"
	Recipe.reindex
	Ingredient.reindex

	puts "Make recipes live"
	Rake::Task["make_recipes_live"].invoke

	puts "Run update recipe stock matches"
	Rake::Task["find_user_add_recipe_stock_matches"].invoke

end