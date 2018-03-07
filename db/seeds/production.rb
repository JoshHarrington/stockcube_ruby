puts "Including required files\n\n"
require 'nokogiri'
require 'set'
require 'uri'


## units
puts "Creating Units table"

unit1 = Unit.create(
   name: "Teaspoon",
   metric_ratio: 5,
   unit_type: "mass"
)

unit2 = Unit.create(
   name: "Tablespoon",
   metric_ratio: 15,
   unit_type: "mass"
)

unit3 = Unit.create(
   name: "Cup",
   metric_ratio: 284.131,
   unit_type: "volume"
)

unit4 = Unit.create(
   name: "Piece",
   metric_ratio: "",
   unit_type: "other" 
)

unit5 = Unit.create(
   name: "Each",
   metric_ratio: "",
   unit_type: "other"
)

unit6 = Unit.create(
   name: "Ounce-weight",
   metric_ratio: 28.35,
   unit_type: "mass"
)

unit7 = Unit.create(
   name: "Pound",
   metric_ratio: 500,
   unit_type: "mass"
)

unit8 = Unit.create(
   name: "Gram",
   metric_ratio: 1,
   unit_type: "mass"
)

unit9 = Unit.create(
   name: "Kilogram",
   metric_ratio: 1000,
   unit_type: "mass"
)

unit10 = Unit.create(
   name: "Fluid ounce",
   metric_ratio: 28.4131,
   unit_type: "volume"
)

unit11 = Unit.create(
   name: "Milliliter",
   metric_ratio: 1,
   unit_type: "volume"
)

unit12 = Unit.create(
   name: "Liter",
   metric_ratio: 1000,
   unit_type: "volume"
)

unit13 = Unit.create(
   name: "Gallon",
   metric_ratio: 3785.4118,
   unit_type: "volume"
)

unit14 = Unit.create(
   name: "Pint",
   metric_ratio: 568.26125,
   unit_type: "volume"
)

unit15 = Unit.create(
   name: "Quart",
   metric_ratio: 1136.52,
   unit_type: "volume"
)

unit16 = Unit.create(
   name: "Milligram",
   metric_ratio: 0.001,
   unit_type: "mass"
)

unit17 = Unit.create(
   name: "Microgram",
   metric_ratio: 0.000001,
   unit_type: "mass"
)

unit18 = Unit.create(
   name: "Intake",
   metric_ratio: "",
   unit_type: "other"
)

unit19 = Unit.create(
   name: "Individual Cup",
   metric_ratio: 284.131,
   unit_type: "volume"
)

unit20 = Unit.create(
   name: "Bottle",
   metric_ratio: "",
   unit_type: "other"
)

unit21 = Unit.create(
   name: "Box",
   metric_ratio: "",
   unit_type: "other"
)

unit22 = Unit.create(
   name: "Can",
   metric_ratio: "",
   unit_type: "other"
)

unit23 = Unit.create(
   name: "Individual Bag",
   metric_ratio: "",
   unit_type: "other"
)

unit24 = Unit.create(
   name: "Cube",
   metric_ratio: "",
   unit_type: "other"
)

unit25 = Unit.create(
   name: "Jar",
   metric_ratio: "",
   unit_type: "other"
)

unit26 = Unit.create(
   name: "Stick",
   metric_ratio: "",
   unit_type: "other"
)

unit27 = Unit.create(
   name: "Tablet",
   metric_ratio: "",
   unit_type: "other"
)

unit28 = Unit.create(
   name: "Bowl",
   metric_ratio: "",
   unit_type: "other"
)

unit29 = Unit.create(
   name: "Meal",
   metric_ratio: "",
   unit_type: "other"
)

unit30 = Unit.create(
   name: "Slice",
   metric_ratio: "",
   unit_type: "other"
)

unit31 = Unit.create(
   name: "Serving",
   metric_ratio: "",
   unit_type: "other"
)

unit32 = Unit.create(
   name: "300 Can",
   metric_ratio: 414.0294,
   unit_type: "volume"
)

unit33 = Unit.create(
   name: "303 Can",
   metric_ratio: 473.176,
   unit_type: "volume"
)

unit34 = Unit.create(
   name: "401 Can",
   metric_ratio: 828.059,
   unit_type: "volume"
)

unit35 = Unit.create(
   name: "404 Can",
   metric_ratio: 1360.382,
   unit_type: "volume"
)

unit36 = Unit.create(
   name: "Individual Packet",
   metric_ratio: "",
   unit_type: "other"
)

unit37 = Unit.create(
   name: "Scoop",
   metric_ratio: "",
   unit_type: "other"
)

unit38 = Unit.create(
   name: "Regular",
   metric_ratio: "",
   unit_type: "other"
)

unit39 = Unit.create(
   name: "Small",
   metric_ratio: "",
   unit_type: "other"
)

unit40 = Unit.create(
   name: "Medium",
   metric_ratio: "",
   unit_type: "other"
)

unit41 = Unit.create(
   name: "Large",
   metric_ratio: "",
   unit_type: "other"
)

unit42 = Unit.create(
   name: "Extra Large",
   metric_ratio: "",
   unit_type: "other"
)

unit43 = Unit.create(
   name: "Individual",
   metric_ratio: "",
   unit_type: "other"
)

unit44 = Unit.create(
   name: "Side",
   metric_ratio: "",
   unit_type: "other"
)

unit45 = Unit.create(
   name: "Appetizer",
   metric_ratio: "",
   unit_type: "other"
)

unit46 = Unit.create(
   name: "Entree",
   metric_ratio: "",
   unit_type: "other"
)

unit47 = Unit.create(
   name: "Capsule",
   metric_ratio: "",
   unit_type: "other"
)

unit48 = Unit.create(
   name: "Kids'",
   metric_ratio: "",
   unit_type: "other"
)

unit49 = Unit.create(
   name: "Whole",
   metric_ratio: "",
   unit_type: "other"
)

unit50 = Unit.create(
   name: "Pat",
   metric_ratio: "",
   unit_type: "other"
)

unit51 = Unit.create(
   name: "Pouch",
   metric_ratio: "",
   unit_type: "other"
)

unit52 = Unit.create(
   name: "Drop",
   metric_ratio: "",
   unit_type: "other"
)

unit53 = Unit.create(
   name: "Jumbo",
   metric_ratio: "",
   unit_type: "other"
)

unit54 = Unit.create(
   name: "Second Spray",
   metric_ratio: "",
   unit_type: "other"
)

unit55 = Unit.create(
   name: "Topping",
   metric_ratio: "",
   unit_type: "other"
)

unit56 = Unit.create(
   name: "Portion Cup",
   metric_ratio: 284.131,
   unit_type: "volume"
)

unit57 = Unit.create(
   name: "Caplet",
   metric_ratio: "",
   unit_type: "other"
)

unit58 = Unit.create(
   name: "Mini",
   metric_ratio: "",
   unit_type: "other"
)

unit59 = Unit.create(
   name: "Cubic Inch",
   metric_ratio: 16.3871,
   unit_type: "volume"
)

unit60 = Unit.create(
   name: "Thin Slice",
   metric_ratio: "",
   unit_type: "other"
)

unit61 = Unit.create(
   name: "Sheet",
   metric_ratio: "",
   unit_type: "other"
)

unit62 = Unit.create(
   name: "Family",
   metric_ratio: "",
   unit_type: "other"
)

unit63 = Unit.create(
   name: "#10 Can",
   metric_ratio: 3409.5675,
   unit_type: "volume"
)

unit64 = Unit.create(
   name: "As Entered",
   metric_ratio: "",
   unit_type: "other"
)

unit65 = Unit.create(
   name: "Order",
   metric_ratio: "",
   unit_type: "other"
)

unit66 = Unit.create(
   name: "Thick Slice",
   metric_ratio: "",
   unit_type: "other"
)

unit67 = Unit.create(
   name: "Dry Serving",
   metric_ratio: "",
   unit_type: "other"
)

unit68 = Unit.create(
   name: "Individual Package",
   metric_ratio: "",
   unit_type: "other"
)

unit69 = Unit.create(
   name: "Bag",
   metric_ratio: "",
   unit_type: "other"
)

unit70 = Unit.create(
   name: "Container",
   metric_ratio: "",
   unit_type: "other"
)

unit71 = Unit.create(
   name: "Package",
   metric_ratio: "",
   unit_type: "other"
)

unit72 = Unit.create(
   name: "Percent",
   metric_ratio: "",
   unit_type: "other"
)

unit73 = Unit.create(
   name: "International Unit",
   metric_ratio: "",
   unit_type: "other"
)

unit74 = Unit.create(
   name: "Calorie",
   metric_ratio: "",
   unit_type: "other"
)

unit75 = Unit.create(
   name: "Retinol Equivalent",
   metric_ratio: "",
   unit_type: "other"
)

unit76 = Unit.create(
   name: "Retinol Activity Equivalent",
   metric_ratio: "",
   unit_type: "other"
)

unit77 = Unit.create(
   name: "Dietary Folate Equivalent",
   metric_ratio: "",
   unit_type: "other"
)

unit78 = Unit.create(
   name: "Ounce Equivalent",
   metric_ratio: 28.35,
   unit_type: "mass"
)

unit79 = Unit.create(
   name: "Cup Equivalent",
   metric_ratio: 284.131,
   unit_type: "volume"
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
      
      ## find the unit for this portion
      unit_obj = Unit.find_or_create_by(id: ingredient_unit)  
      ## add the portion to the unit
      unit_obj.portions << portion_obj
      
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


puts "Add special characterists to ingredients eg. gluten free and veggier"

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
      end
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

puts "Creating example user"

me = User.create(name:  "Example User",
email: ENV['PERSONAL_EMAIL'],
password:              ENV['PERSONAL_PASSWORD'],
password_confirmation: ENV['PERSONAL_PASSWORD'],
admin: true,
activated: true,
activated_at: Time.zone.now)

puts "Example user created"
