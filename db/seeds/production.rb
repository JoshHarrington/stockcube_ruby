puts "Including required files\n\n"
require 'nokogiri'
require 'set'
require 'uri'
require 'date'


## units
puts "Creating Units and adding to table"

## load units create from partial
require('./db/seeds/partials/create_units.rb')

puts "Units tables complete\n\n"

## recipes
puts "Starting recipes logic to add ingredients and recipes to tables"

## load create recipes and ingredients from partial
require('./db/seeds/partials/create_recipes_and_ingredients.rb')

puts "Recipes and relevant portions created\n\n"


puts "Update ingredients attributes eg. whether gluten free or veggie"

## load update ingredient attributes from partial
require('./db/seeds/partials/update_ingredient_attributes.rb')

puts "Finished updating ingredient attributes\n\n"


puts "Create admin and standard users, create cupboards, add stock to cupboards"

## load add stock to cupboards from partial
require('./db/seeds/partials/create_users_cupboards_add_stock.rb')

puts "Stock added to cupboards"
