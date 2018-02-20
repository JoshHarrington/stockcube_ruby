require 'nokogiri'
require 'set'
require 'uri'

# # This file should contain all the record creation needed to seed the database with its default values.
# # The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# #
# # Examples:
# #
# #   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
# #   Mayor.create(name: 'Emanuel', city: cities.first)

veggieRecipesXML = File.read("./db/foodDBs/VegetarianRecipes.exl")
worldRecipesXML = File.read("./db/foodDBs/WorldRecipes.exl")

recipes = Nokogiri::XML(veggieRecipesXML)
worldRecipes = Nokogiri::XML(worldRecipesXML).search('data')

recipes.at('data').add_child(worldRecipes)

foodRegex = "(, boiled.*)|(, blanched.*)|(, california.*)|(, pan fried.*)|(, braised.*)|(, roasted.*)|(, chuck clod.*)|(, fresh.*)|(, salad or.*)|(, instant.*)|(, prepared.*)|(, sliced.*)|(, canned.*)|(, salted.*)|(, dry roasted.*)|(, plain.*)|(, double acting.*)|(, Eagle.*)|(, from .*)|(, degerminated.*)|(, ground.*)|(, all purpose.*)|(, pastry.*)|(, white.*)|(, cooked.*)|(, grated.*)|(, shredded.*)|(, organic.*)|(, dash.*)|(, whole grain.*)|(, chopped.*)|(, extracted.*)|(, unsweetened.*)|(, frozen.*)|(, red, California.*)|(, old fashioned.*)|(, dry.*)|(, original.*)|(, TSP.*)|(, seedless.*)|(, without seeds.*)|(, table.*)|(, brown.*)|(, with calcium.*)|(, winter.*)|(, powdered.*)|(, silken.*)|(, with nigari.*)|(, unsalted.*)|(, crushed.*)|(, stewed.*)|(, filtered.*)|(, natural.*)|(, municipal.*)|(, regular.*)|(, baked.*)|(, active.*)|(, steamed.*)|(, ready to.*)|(, diced.*)|(, powder.*)|(, defatted.*)|(, toasted.*)|(, hulled.*)|(, oriental.*)|(, daikon.*)|(, halves.*)|(, creamy.*)|(, flakes.*)|(, vital.*)|(, slivered.*)|(, 60 grain.*)|(, raw.*)|(, top round.*)|(, top sirloin.*)|(, chuck.*)|(, dehydrated.*)|(, seasoned.*)|(, low moisture.*)|(, roasted.*)|(, whole.*)|(, kernels.*)|(, 50 grain.*)|(, refrigerated.*)|(, smoked.*)|(, food service.*)|(, elegant.*)|(, chilled.*)"
recipeRegex = "(Copyright.*)"

ingredients_set = Set[]

recipes.css('recipe').each_with_index do |recipe, recipe_index|

	recipe.children.css('RecipeItem').each do |ingredient|

		## define ingredient
		ingredient_name = ingredient['ItemName']
    ingredient_name = ingredient_name.gsub(/#{foodRegex}/, '').downcase
    
    if ingredient_name.include? ","
      ingredient_name = ingredient_name.split(', ', 2)
      ingredient_main_title = ingredient_name[0].titleize
      ingredient_title_detail = " (" + ingredient_name[1].titleize + ")"
      ingredient_name = ingredient_main_title + ingredient_title_detail
    else
      ingredient_name = ingredient_name.titleize
    end

		ingredients_set.add(ingredient_name)

	end

end


sorted_ingredients = ingredients_set.sort

sorted_ingredients.to_a.each_with_index do |ingredient, index|
	ingredient_new = Ingredient.create("name": ingredient)
end


recipes.css('recipe').each_with_index do |recipe, recipe_index|

  recipe_title = recipe['description']
  recipe_desc = Array.new


  recipe.children.css('XML_MEMO1').each do |description|
    # safe_desc = URI.escape(description.inner_text)
    recipe_desc << description.inner_text
  end

  recipe_desc = recipe_desc.join('').gsub(/#{recipeRegex}/, '')

	recipe_new = Recipe.create(title: recipe_title, description: recipe_desc.to_s)

	recipe.children.css('RecipeItem').each do |ingredient|

		## define ingredient
		ingredient_name = ingredient['ItemName']
    ingredient_name = ingredient_name.gsub(/#{foodRegex}/, '').downcase

    if ingredient_name.include? ","
      ingredient_name = ingredient_name.split(', ', 2)
      ingredient_main_title = ingredient_name[0].titleize
      ingredient_title_detail = " (" + ingredient_name[1].titleize + ")"
      ingredient_name = ingredient_main_title + ingredient_title_detail
    else
      ingredient_name = ingredient_name.titleize
    end

    ingredient_obj = Ingredient.find_or_create_by(name: ingredient_name)

		recipe_new.ingredients << ingredient_obj
  end
  

end




c1 = Cupboard.create(location: "Fridge Door")
c2 = Cupboard.create(location: "Fridge Bottom Drawer")
c3 = Cupboard.create(location: "Fridge Top Shelf")
c4 = Cupboard.create(location: "Cupboard by the Oven")

# c1.ingredients << [i5, i7, i8]
# c2.ingredients << [i6, i12, i13, i16]
# c3.ingredients << [i18, i19, i20, i21]
# c4.ingredients << [i24, i25, i26, i28, i31]

User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
						 password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end