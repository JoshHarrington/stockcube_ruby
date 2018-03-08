puts "Including required files\n\n"
require 'nokogiri'
require 'set'
require 'uri'
require 'date'


## units
puts "Creating Units table"

unit1 = Unit.create(
  unit_number: 1, 
  name: "Teaspoon",
  short_name: "Tsp",
  metric_ratio: 5,
  unit_type: "mass"
)

unit2 = Unit.create(
  unit_number: 2, 
  name: "Tablespoon",
  short_name: "Tbsp",
  metric_ratio: 15,
  unit_type: "mass"
)

unit3 = Unit.create(
  unit_number: 3, 
  name: "Cup",
  metric_ratio: 284.131,
  unit_type: "volume"
)

unit4 = Unit.create(
  unit_number: 4, 
  name: "Piece",
  unit_type: "other" 
)

unit5 = Unit.create(
  unit_number: 5, 
  name: "Each",
  unit_type: "other"
)

unit6 = Unit.create(
  unit_number: 6, 
  name: "Ounce",
  short_name: "Oz",
  metric_ratio: 28.35,
  unit_type: "mass"
)

unit7 = Unit.create(
  unit_number: 7, 
  name: "Pound",
  short_name: "Lb",
  metric_ratio: 500,
  unit_type: "mass"
)

unit8 = Unit.create(
  unit_number: 8, 
  name: "Gram",
  short_name: "G",
  metric_ratio: 1,
  unit_type: "mass"
)

unit9 = Unit.create(
  unit_number: 9, 
  name: "Kilogram",
  short_name: "Kg",
  metric_ratio: 1000,
  unit_type: "mass"
)

unit10 = Unit.create(
  unit_number: 10, 
  name: "Fluid ounce",
  short_name: "Fluid oz",
  metric_ratio: 28.4131,
  unit_type: "volume"
)

unit11 = Unit.create(
  unit_number: 11, 
  name: "Milliliter",
  short_name: "Ml",
  metric_ratio: 1,
  unit_type: "volume"
)

unit12 = Unit.create(
  unit_number: 12, 
  name: "Liter",
  short_name: "L",
  metric_ratio: 1000,
  unit_type: "volume"
)

unit13 = Unit.create(
  unit_number: 13, 
  name: "Gallon",
  short_name: "Gal",
  metric_ratio: 3785.4118,
  unit_type: "volume"
)

unit14 = Unit.create(
  unit_number: 14, 
  name: "Pint",
  short_name: "Pt",
  metric_ratio: 568.26125,
  unit_type: "volume"
)

unit15 = Unit.create(
  unit_number: 15, 
  name: "Quart",
  short_name: "Qt",
  metric_ratio: 1136.52,
  unit_type: "volume"
)

unit16 = Unit.create(
  unit_number: 16, 
  name: "Milligram",
  short_name: "Mg",
  metric_ratio: 0.001,
  unit_type: "mass"
)

unit17 = Unit.create(
  unit_number: 17, 
  name: "Microgram",
  short_name: "µg",
  metric_ratio: 0.000001,
  unit_type: "mass"
)

unit18 = Unit.create(
  unit_number: 18, 
  name: "Intake",
  unit_type: "other"
)

unit20 = Unit.create(
  unit_number: 20, 
  name: "Bottle",
  unit_type: "other"
)

unit21 = Unit.create(
  unit_number: 21, 
  name: "Box",
  unit_type: "other"
)

unit22 = Unit.create(
  unit_number: 22, 
  name: "Can",
  unit_type: "other"
)

unit23 = Unit.create(
  unit_number: 23, 
  name: "Individual Bag",
  unit_type: "other"
)

unit24 = Unit.create(
  unit_number: 24, 
  name: "Cube",
  unit_type: "other"
)

unit25 = Unit.create(
  unit_number: 25, 
  name: "Jar",
  unit_type: "other"
)

unit26 = Unit.create(
  unit_number: 26, 
  name: "Stick",
  unit_type: "other"
)

unit27 = Unit.create(
  unit_number: 27, 
  name: "Tablet",
  unit_type: "other"
)

unit28 = Unit.create(
  unit_number: 28, 
  name: "Bowl",
  unit_type: "other"
)

unit29 = Unit.create(
  unit_number: 29, 
  name: "Meal",
  unit_type: "other"
)

unit30 = Unit.create(
  unit_number: 30, 
  name: "Slice",
  unit_type: "other"
)

unit31 = Unit.create(
  unit_number: 31, 
  name: "Serving",
  unit_type: "other"
)

unit32 = Unit.create(
  unit_number: 32, 
  name: "300 Can",
  metric_ratio: 414.0294,
   unit_type: "volume"
)

unit33 = Unit.create(
  unit_number: 33, 
  name: "303 Can",
  metric_ratio: 473.176,
  unit_type: "volume"
)

unit34 = Unit.create(
  unit_number: 34, 
  name: "401 Can",
  metric_ratio: 828.059,
  unit_type: "volume"
)

unit35 = Unit.create(
  unit_number: 35, 
  name: "404 Can",
  metric_ratio: 1360.382,
  unit_type: "volume"
)

unit36 = Unit.create(
  unit_number: 36, 
  name: "Individual Packet",
  unit_type: "other"
)

unit37 = Unit.create(
  unit_number: 37, 
  name: "Scoop",
  unit_type: "other"
)

unit38 = Unit.create(
  unit_number: 38, 
  name: "Regular",
  unit_type: "other"
)

unit39 = Unit.create(
  unit_number: 39, 
  name: "Small",
  unit_type: "other"
)

unit40 = Unit.create(
  unit_number: 40, 
  name: "Medium",
  unit_type: "other"
)

unit41 = Unit.create(
  unit_number: 41, 
  name: "Large",
  unit_type: "other"
)

unit42 = Unit.create(
  unit_number: 42, 
  name: "Extra Large",
  unit_type: "other"
)

unit43 = Unit.create(
  unit_number: 43, 
  name: "Individual",
  unit_type: "other"
)

unit44 = Unit.create(
  unit_number: 44, 
  name: "Side",
  unit_type: "other"
)

unit45 = Unit.create(
  unit_number: 45, 
  name: "Appetizer",
  unit_type: "other"
)

unit46 = Unit.create(
  unit_number: 46, 
  name: "Entree",
  unit_type: "other"
)

unit47 = Unit.create(
  unit_number: 47, 
  name: "Capsule",
  unit_type: "other"
)

unit48 = Unit.create(
  unit_number: 48, 
  name: "Kids'",
  unit_type: "other"
)

unit49 = Unit.create(
  unit_number: 49, 
  name: "Whole",
  unit_type: "other"
)

unit50 = Unit.create(
  unit_number: 50, 
  name: "Pat",
  unit_type: "other"
)

unit51 = Unit.create(
  unit_number: 51, 
  name: "Pouch",
  unit_type: "other"
)

unit52 = Unit.create(
  unit_number: 52, 
  name: "Drop",
  unit_type: "other"
)

unit53 = Unit.create(
  unit_number: 53, 
  name: "Jumbo",
  unit_type: "other"
)

unit54 = Unit.create(
  unit_number: 54, 
  name: "Second Spray",
  unit_type: "other"
)

unit55 = Unit.create(
  unit_number: 55, 
  name: "Topping",
  unit_type: "other"
)

unit57 = Unit.create(
  unit_number: 57, 
  name: "Caplet",
  unit_type: "other"
)

unit58 = Unit.create(
  unit_number: 58, 
  name: "Mini",
  unit_type: "other"
)

unit59 = Unit.create(
  unit_number: 59, 
  name: "Cubic Inch",
  short_name: "Cu inch",
  metric_ratio: 16.3871,
  unit_type: "volume"
)

unit60 = Unit.create(
  unit_number: 60, 
  name: "Thin Slice",
  unit_type: "other"
)

unit61 = Unit.create(
  unit_number: 61, 
  name: "Sheet",
  unit_type: "other"
)

unit62 = Unit.create(
  unit_number: 62, 
  name: "Family",
  unit_type: "other"
)

unit63 = Unit.create(
  unit_number: 63, 
  name: "#10 Can",
  metric_ratio: 3409.5675,
  unit_type: "volume"
)

unit64 = Unit.create(
  unit_number: 64, 
  name: "As Entered",
  unit_type: "other"
)

unit65 = Unit.create(
  unit_number: 65, 
  name: "Order",
  unit_type: "other"
)

unit66 = Unit.create(
  unit_number: 66, 
  name: "Thick Slice",
  unit_type: "other"
)

unit67 = Unit.create(
  unit_number: 67, 
  name: "Dry Serving",
  unit_type: "other"
)

unit68 = Unit.create(
  unit_number: 68, 
  name: "Individual Package",
  unit_type: "other"
)

unit69 = Unit.create(
  unit_number: 69, 
  name: "Bag",
  unit_type: "other"
)

unit70 = Unit.create(
  unit_number: 70, 
  name: "Container",
  unit_type: "other"
)

unit71 = Unit.create(
  unit_number: 71, 
  name: "Package",
  unit_type: "other"
)

unit72 = Unit.create(
  unit_number: 72, 
  name: "Percent",
  unit_type: "other"
)

unit73 = Unit.create(
  unit_number: 73, 
  name: "International Unit",
  unit_type: "other"
)

unit74 = Unit.create(
  unit_number: 74, 
  name: "Calorie",
  unit_type: "other"
)

unit75 = Unit.create(
  unit_number: 75, 
  name: "Retinol Equivalent",
  unit_type: "other"
)

unit76 = Unit.create(
  unit_number: 76, 
  name: "Retinol Activity Equivalent",
  unit_type: "other"
)

unit77 = Unit.create(
  unit_number: 77, 
  name: "Dietary Folate Equivalent",
  unit_type: "other"
)

puts "Units tables created\n\n"

## recipes
puts "Starting recipes logic to add ingredients and recipes to tables"

veggieRecipesXML = File.read("./db/foodDBs/VegetarianRecipes.exl")
worldRecipesXML = File.read("./db/foodDBs/WorldRecipes.exl")

recipes = Nokogiri::XML(veggieRecipesXML)
worldRecipes = Nokogiri::XML(worldRecipesXML).search('data')

recipes = recipes.at('data').add_child(worldRecipes)

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
  ingredient_new = Ingredient.find_or_create_by(name: ingredient)
end

puts "Ingredients created"


recipes.css('recipe').each_with_index do |recipe, recipe_index|

  recipe_title = recipe['description']
  recipe_desc = Array.new


  recipe.children.css('XML_MEMO1').each do |description|
    recipe_desc << description.inner_text
  end

  recipe_desc = recipe_desc.join('').gsub(/#{recipeRegex}/, '')

	recipe_new = Recipe.create(title: recipe_title, description: recipe_desc.to_s)

	recipe.children.css('RecipeItem').each do |ingredient|

		## define ingredient
    ingredient_name = ingredient['ItemName']
    ingredient_unit = ingredient['itemMeasureKey'].to_s
    ingredient_amount = ingredient['itemQuantity'].to_s
    ingredient_name = ingredient_name.gsub(/#{foodRegex}/, '').downcase

    ## if the ingredient name contains commas then ...
    if ingredient_name.include? ","
      ## create array from ingredient name
      ingredient_name = ingredient_name.split(', ', 2)
      ## take first string from ingredient name array and Titleize it
      ingredient_main_title = ingredient_name[0].titleize
      ## take the second array from the ingredient name and put it inside brackets
      ingredient_title_detail = " (" + ingredient_name[1].titleize + ")"
      ## combine the ingredient title and detail to form name
      ingredient_name = ingredient_main_title + ingredient_title_detail
    else
      ## titleize the ingredient name if it doesn't contain commas
      ingredient_name = ingredient_name.titleize
    end

    ingredient_obj = Ingredient.where(name: ingredient_name).first

    ## make sure we only use the first ingredient of a name in a recipe list (there are duplicates!)
    if not recipe_new.ingredients.include?(ingredient_obj)
      ## create the ingredient based on its name unless it already exists
      ingredient_obj = Ingredient.where(name: ingredient_name).first
      
      ## add the ingredient to the recipe's ingredients
      recipe_new.ingredients << ingredient_obj

      ## find the portion for the recipe and ingredient ids
      portion_obj = Portion.where(recipe_id: recipe_new.id, ingredient_id: ingredient_obj.id).first

      ## catch the ingredients with units which already match a more common unit
      if ingredient_unit == 19 || ingredient_unit == 56 || ingredient_unit == 79
        ## catch ingredients with units the same as ounces (unit3)
        unit_obj = Unit.find_or_create_by(unit_number: 3)  
      elsif ingredient_unit == 78
        ## catch ingredients with units the same as cups (unit6)
        unit_obj = Unit.find_or_create_by(unit_number: 6)  
      else
        ## otherwise find the correct unit object
        unit_obj = Unit.find_or_create_by(unit_number: ingredient_unit)  
      end
      ## link the units and ingredients tables on the correct unit
      unit_obj.ingredients << ingredient_obj
      
      ## update the portions ingredient amount
      portion_obj.update_attributes(
        :amount => ingredient_amount
      )
      
    else
      puts " -- duplicate data (same ingredient in recipe), skipping"
    end
  end

end

puts "Recipes and relevant portions created\n\n"


puts "Add special characterists to ingredients eg. gluten free and veggie"

## array to check whether ingredients should be made searchable or not
not_searchable = ["Condiments ", "Beverages", "Fats Oils ", "Baking Ingredients"]

## ??? should check if ingredient has previously been edited 
## to ensure that it's not overwritten loads of times

recipes.css('ingredient').each_with_index do |ingredient, ingredient_index|
  ingredient_name = ingredient['description']
  ingredient_name = ingredient_name.gsub(/#{foodRegex}/, '').downcase

  ## if the ingredient name contains commas then ...
  if ingredient_name.include? ","
    ## create array from ingredient name
    ingredient_name = ingredient_name.split(', ', 2)
    ## take first string from ingredient name array and Titleize it
    ingredient_main_title = ingredient_name[0].titleize
    ## take the second array from the ingredient name and put it inside brackets
    ingredient_title_detail = " (" + ingredient_name[1].titleize + ")"
    ## combine the ingredient title and detail to form name
    ingredient_name = ingredient_main_title + ingredient_title_detail
  else
    ## titleize the ingredient name if it doesn't contain commas
    ingredient_name = ingredient_name.titleize
  end

  ingredient_obj = Ingredient.where(name: ingredient_name).first

  ## ingredient_obj is not necessary selected at this point, check it exists
  if ingredient_obj
    ingredient.children.css('GroupData Group').each do |detail|
      ingredient_status = detail['groupName']
      if ingredient_status.to_s == "Vegan"
        ingredient_obj.update_attributes(
          :vegan => true
        )
      elsif ingredient_status.to_s == "Vegetarian/Lactovo"
        ingredient_obj.update_attributes(
          :vegetarian => true
        )
      elsif ingredient_status.to_s == "Gluten Free"
        ingredient_obj.update_attributes(
          :gluten_free => true
        )
      elsif ingredient_status.to_s == "Dairy Free"
        ingredient_obj.update_attributes(
          :dairy_free => true
        )
      elsif ingredient_status.to_s == "Kosher"
        ingredient_obj.update_attributes(
          :kosher => true
        )
      elsif not_searchable.any? { |attribute| ingredient_status.to_s.include?(attribute)}
        ingredient_obj.update_attributes(
          :searchable => false
        )
      end
    end
    if ingredient_obj.recipes.length > 5
      ingredient_obj.update_attributes(
        :common => true
      )
    end
    
  end
end


puts "Finished adding ingredient statuses\n\n"


puts "Creating Cupboards"

c1 = Cupboard.create(location: "Fridge Door")
c2 = Cupboard.create(location: "Fridge Bottom Drawer")
c3 = Cupboard.create(location: "Fridge Top Shelf")
c4 = Cupboard.create(location: "Cupboard by the Oven")

puts "Cupboards created\n\n"


### todo - setup some ingredients to be added to cupboard locations

puts "Creating users"

me = User.create(name:  "Example User",
email: ENV['PERSONAL_EMAIL'],
password:              ENV['PERSONAL_PASSWORD'],
password_confirmation: ENV['PERSONAL_PASSWORD'],
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

puts "Users created\n\n"

puts "Adding cupboards to users"

me.cupboards << [c1, c2, c3, c4]

puts "Cupboards added to users\n\n"

puts "Creating example stock in cupboards"

10.times do |n|
  ## find one of the first 10 ingredients in the ingredients table
  ingredient_obj = Ingredient.where(id: n).first

  ## if the ingredient exists then put ingredients in a cupboard
  if ingredient_obj 
    ## find the number of cupboards associated with the example user
    num_of_cupboards = me.cupboards.length
    ## pick one of these cupboards at random
    cupboard_pick = 1 + Random.rand(num_of_cupboards)
    ## select this cupboard
    cupboard = me.cupboards.where(id: cupboard_pick).first

    ## add the selected ingredient to the cupboard
    cupboard.ingredients << ingredient_obj

    ## select the stock object based on it's cupboard and ingredient id
    stocky_obj = Stock.where(cupboard_id: cupboard.id, ingredient_id: ingredient_obj.id).first

    random_use_by = Date.today + 2.weeks + n.days

    ## update the stock objects attributes
    stocky_obj.update_attributes(
      :amount => 0.1,
      :use_by_date => random_use_by
    )
  end
end

puts "Stock added to cupboards"
