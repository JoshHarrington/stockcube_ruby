require 'nokogiri'
require 'set'

recipesXML = File.read("./db/VegetarianRecipes.exl")
recipes = Nokogiri::XML(recipesXML)

foodRegex = "(, boiled.*)|(, fresh.*)|(, salad or.*)|(, instant.*)|(, prepared.*)|(, sliced.*)|(, canned.*)|(, salted.*)|(, dry roasted.*)|(, plain.*)|(, double acting.*)|(, Eagle.*)|(, from .*)|(, degerminated.*)|(, ground.*)|(, all purpose.*)|(, pastry.*)|(, white.*)|(, cooked.*)|(, grated.*)|(, shredded.*)|(, organic.*)|(, dash.*)|(, whole grain.*)|(, chopped.*)|(, extracted.*)|(, unsweetened.*)|(, frozen.*)|(, red, California.*)|(, old fashioned.*)|(, dry.*)|(, original.*)|(, TSP.*)|(, seedless.*)|(, without seeds.*)|(, table.*)|(, brown.*)|(, with calcium.*)|(, winter.*)|(, powdered.*)|(, silken.*)|(, with nigari.*)|(, unsalted.*)|(, crushed.*)|(, stewed.*)|(, filtered.*)|(, natural.*)|(, municipal.*)|(, regular.*)|(, baked.*)|(, active.*)|(, steamed.*)|(, ready to.*)|(, diced.*)|(, powder.*)|(, defatted.*)|(, toasted.*)|(, hulled.*)|(, oriental.*)|(, daikon.*)|(, halves.*)|(, creamy.*)|(, flakes.*)|(, vital.*)|(, slivered.*)|(, 60 grain.*)|(, raw.*)"


ingredients_set = Set[]

recipes.css('recipe').each_with_index do |recipe, recipe_index|

	recipe.children.css('RecipeItem').each do |ingredient|

		## define ingredient
		ingredient_name = ingredient['ItemName']
		ingredient_name = ingredient_name.gsub(/#{foodRegex}/, '').downcase

		ingredients_set.add(ingredient_name)

	end

	recipe_title = recipe['description']

	recipe_key = (recipe_index+1).to_s
	recipe_key = "m" + recipe_key
	recipe_key = Meal.create(name: recipe_title)

end

sorted_ingredients = ingredients_set.sort

ingredients_hash = {}

sorted_ingredients.to_a.each_with_index do |ingredient, index|
	ingredients_hash = ingredients_hash.merge("i"+(index + 1).to_s => ingredient)
end

puts ingredients_hash


sorted_ingredients.to_a.each_with_index do |ingredient, index|
	ingredient_key = (index+1).to_s
	ingredient_key = "i" + ingredient_key
	ingredient_key = Ingredient.create(name: ingredient)
end


recipes.css('recipe').each_with_index do |recipe, recipe_index|

	recipe_title = recipe['description']

	recipe_key = (recipe_index+1).to_s
	recipe_key = "m" + recipe_key

	recipe.children.css('RecipeItem').each do |ingredient|

		## define ingredient
		ingredient_name = ingredient['ItemName']
		ingredient_name = ingredient_name.gsub(/#{foodRegex}/, '').downcase

		ingredients_set.add(ingredient_name)

		ingredient_id = ingredients_hash.key(ingredient_name)

		recipe_key.ingredients << ingredient_id 
	end

end