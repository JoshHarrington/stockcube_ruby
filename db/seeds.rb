puts "Including required files\n\n"
require 'nokogiri'
require 'uri'
require 'date'


unless Unit.exists?(id: 3)
	## units
	puts "Creating Units and adding to table"

	## load units create from partial
	require('./db/seeds/partials/create_units.rb')

	puts "Units tables complete\n\n"
end


unless Recipe.exists?(id: 3) && Ingredient.exists?(id: 3)
	## recipes
	puts "Starting recipes logic to add ingredients and recipes to tables"

	if not Rails.env.downcase == "production"
		## include recipe global variables
		require('./db/seeds/partials/_recipe_global_vars.rb')
	end

	## load create recipes and ingredients from partial
	require('./db/seeds/partials/create_recipes_and_ingredients.rb')

	puts "Recipes and relevant portions created\n\n"


	puts "Update ingredients attributes eg. whether gluten free or veggie"

	## load update ingredient attributes from partial
	require('./db/seeds/partials/update_ingredient_attributes.rb')

	puts "Finished updating ingredient attributes\n\n"
end

## ## ## Cupboard.all.destroy_all
## ## ## Stock.all.destroy_all
## ## ## ShoppingList.all.destroy_all
## ## ## User.all.destroy_all

unless User.exists?(admin: true) && Cupboard.exists?(id: 1)

	puts "Create admin and standard users, create cupboards, add stock to cupboards"

	## load add stock to cupboards from partial
	require('./db/seeds/partials/create_users_cupboards_add_stock.rb')

	puts "Stock added to cupboards\n\n"

end

unless User.exists?(admin: false)
	if not Rails.env.downcase == "production"

		puts "Creating fake test users"

		## load dev only create users from partial
		require('./db/seeds/partials/dev_create_test_users.rb')

		puts "Test users created\n\n"

	end
end

unless ShoppingList.exists?(id: 1)
	puts "Creating shopping lists"

	## load create shopping lists from partial
	require('./db/seeds/partials/create_shopping_lists.rb')

	puts "Shopping lists created\n\n"
end

puts "FINISHED!\n\n"
