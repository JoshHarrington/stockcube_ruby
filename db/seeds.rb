require 'nokogiri'
require 'set'
require 'uri'

## recipes

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
	ingredient_new = Ingredient.create("name": ingredient)
end


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
    ingredient_unit = ingredient['itemMeasureKey']
    ingredient_amount = ingredient['itemQuantity']
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

    ## create the ingredient based on its name unless it already exists
    ingredient_obj = Ingredient.find_or_create_by(name: ingredient_name)

    ## add the ingredient to the recipe's ingredients
    recipe_new.ingredients << ingredient_obj
    portion_obj = Portion.where(:recipe_id => recipe_new.id, :ingredient_id => ingredient_obj.id).first_or_create
    portion_obj.update_attributes(
      :amount => ingredient_amount,
      :unit => ingredient_unit
    )

  end

end

## units

unit1 = Unit.create(
   id: 1,
   name: "Teaspoon",
   metric_ratio: 5,
   unit_type: "mass"
)

unit2 = Unit.create(
   id: 2,
   name: "Tablespoon",
   metric_ratio: 15,
   unit_type: "mass"
)

unit3 = Unit.create(
   id: 3,
   name: "Cup",
   metric_ratio: 284.131,
   unit_type: "volume"
)

unit4 = Unit.create(
   id: 4,
   name: "Piece",
   metric_ratio: "",
   unit_type: "other" 
)

unit5 = Unit.create(
   id: 5,
   name: "Each",
   metric_ratio: "",
   unit_type: "other"
)

unit6 = Unit.create(
   id: 6,
   name: "Ounce-weight",
   metric_ratio: 28.35,
   unit_type: "mass"
)

unit7 = Unit.create(
   id: 7,
   name: "Pound",
   metric_ratio: 500,
   unit_type: "mass"
)

unit8 = Unit.create(
   id: 8,
   name: "Gram",
   metric_ratio: 1,
   unit_type: "mass"
)

unit9 = Unit.create(
   id: 9,
   name: "Kilogram",
   metric_ratio: 1000,
   unit_type: "mass"
)

unit10 = Unit.create(
   id: 10,
   name: "Fluid ounce",
   metric_ratio: 28.4131,
   unit_type: "volume"
)

unit11 = Unit.create(
   id: 11,
   name: "Milliliter",
   metric_ratio: 1,
   unit_type: "volume"
)

unit12 = Unit.create(
   id: 12,
   name: "Liter",
   metric_ratio: 1000,
   unit_type: "volume"
)

unit13 = Unit.create(
   id: 13,
   name: "Gallon",
   metric_ratio: 3785.4118,
   unit_type: "volume"
)

unit14 = Unit.create(
   id: 14,
   name: "Pint",
   metric_ratio: 568.26125,
   unit_type: "volume"
)

unit15 = Unit.create(
   id: 15,
   name: "Quart",
   metric_ratio: 1136.52,
   unit_type: "volume"
)

unit16 = Unit.create(
   id: 16,
   name: "Milligram",
   metric_ratio: 0.001,
   unit_type: "mass"
)

unit17 = Unit.create(
   id: 17,
   name: "Microgram",
   metric_ratio: 0.000001,
   unit_type: "mass"
)

unit18 = Unit.create(
   id: 18,
   name: "Intake",
   metric_ratio: "",
   unit_type: "other"
)

unit19 = Unit.create(
   id: 19,
   name: "Individual Cup",
   metric_ratio: 284.131,
   unit_type: "volume"
)

unit20 = Unit.create(
   id: 20,
   name: "Bottle",
   metric_ratio: "",
   unit_type: "other"
)

unit21 = Unit.create(
   id: 21,
   name: "Box",
   metric_ratio: "",
   unit_type: "other"
)

unit22 = Unit.create(
   id: 22,
   name: "Can",
   metric_ratio: "",
   unit_type: "other"
)

unit23 = Unit.create(
   id: 23,
   name: "Individual Bag",
   metric_ratio: "",
   unit_type: "other"
)

unit24 = Unit.create(
   id: 24,
   name: "Cube",
   metric_ratio: "",
   unit_type: "other"
)

unit25 = Unit.create(
   id: 25,
   name: "Jar",
   metric_ratio: "",
   unit_type: "other"
)

unit26 = Unit.create(
   id: 26,
   name: "Stick",
   metric_ratio: "",
   unit_type: "other"
)

unit27 = Unit.create(
   id: 27,
   name: "Tablet",
   metric_ratio: "",
   unit_type: "other"
)

unit28 = Unit.create(
   id: 28,
   name: "Bowl",
   metric_ratio: "",
   unit_type: "other"
)

unit29 = Unit.create(
   id: 29,
   name: "Meal",
   metric_ratio: "",
   unit_type: "other"
)

unit30 = Unit.create(
   id: 30,
   name: "Slice",
   metric_ratio: "",
   unit_type: "other"
)

unit31 = Unit.create(
   id: 31,
   name: "Serving",
   metric_ratio: "",
   unit_type: "other"
)

unit32 = Unit.create(
   id: 32,
   name: "300 Can",
   metric_ratio: 414.0294,
   unit_type: "volume"
)

unit33 = Unit.create(
   id: 33,
   name: "303 Can",
   metric_ratio: 473.176,
   unit_type: "volume"
)

unit34 = Unit.create(
   id: 34,
   name: "401 Can",
   metric_ratio: 828.059,
   unit_type: "volume"
)

unit35 = Unit.create(
   id: 35,
   name: "404 Can",
   metric_ratio: 1360.382,
   unit_type: "volume"
)

unit36 = Unit.create(
   id: 36,
   name: "Individual Packet",
   metric_ratio: "",
   unit_type: "other"
)

unit37 = Unit.create(
   id: 37,
   name: "Scoop",
   metric_ratio: "",
   unit_type: "other"
)

unit38 = Unit.create(
   id: 38,
   name: "Regular",
   metric_ratio: "",
   unit_type: "other"
)

unit39 = Unit.create(
   id: 39,
   name: "Small",
   metric_ratio: "",
   unit_type: "other"
)

unit40 = Unit.create(
   id: 40,
   name: "Medium",
   metric_ratio: "",
   unit_type: "other"
)

unit41 = Unit.create(
   id: 41,
   name: "Large",
   metric_ratio: "",
   unit_type: "other"
)

unit42 = Unit.create(
   id: 42,
   name: "Extra Large",
   metric_ratio: "",
   unit_type: "other"
)

unit43 = Unit.create(
   id: 43,
   name: "Individual",
   metric_ratio: "",
   unit_type: "other"
)

unit44 = Unit.create(
   id: 44,
   name: "Side",
   metric_ratio: "",
   unit_type: "other"
)

unit45 = Unit.create(
   id: 45,
   name: "Appetizer",
   metric_ratio: "",
   unit_type: "other"
)

unit46 = Unit.create(
   id: 46,
   name: "Entree",
   metric_ratio: "",
   unit_type: "other"
)

unit47 = Unit.create(
   id: 47,
   name: "Capsule",
   metric_ratio: "",
   unit_type: "other"
)

unit48 = Unit.create(
   id: 48,
   name: "Kids'",
   metric_ratio: "",
   unit_type: "other"
)

unit49 = Unit.create(
   id: 49,
   name: "Whole",
   metric_ratio: "",
   unit_type: "other"
)

unit50 = Unit.create(
   id: 50,
   name: "Pat",
   metric_ratio: "",
   unit_type: "other"
)

unit51 = Unit.create(
   id: 51,
   name: "Pouch",
   metric_ratio: "",
   unit_type: "other"
)

unit52 = Unit.create(
   id: 52,
   name: "Drop",
   metric_ratio: "",
   unit_type: "other"
)

unit53 = Unit.create(
   id: 53,
   name: "Jumbo",
   metric_ratio: "",
   unit_type: "other"
)

unit54 = Unit.create(
   id: 54,
   name: "Second Spray",
   metric_ratio: "",
   unit_type: "other"
)

unit55 = Unit.create(
   id: 55,
   name: "Topping",
   metric_ratio: "",
   unit_type: "other"
)

unit56 = Unit.create(
   id: 56,
   name: "Portion Cup",
   metric_ratio: 284.131,
   unit_type: "volume"
)

unit57 = Unit.create(
   id: 57,
   name: "Caplet",
   metric_ratio: "",
   unit_type: "other"
)

unit58 = Unit.create(
   id: 58,
   name: "Mini",
   metric_ratio: "",
   unit_type: "other"
)

unit59 = Unit.create(
   id: 59,
   name: "Cubic Inch",
   metric_ratio: 16.3871,
   unit_type: "volume"
)

unit60 = Unit.create(
   id: 60,
   name: "Thin Slice",
   metric_ratio: "",
   unit_type: "other"
)

unit61 = Unit.create(
   id: 61,
   name: "Sheet",
   metric_ratio: "",
   unit_type: "other"
)

unit62 = Unit.create(
   id: 62,
   name: "Family",
   metric_ratio: "",
   unit_type: "other"
)

unit63 = Unit.create(
   id: 63,
   name: "#10 Can",
   metric_ratio: 3409.5675,
   unit_type: "volume"
)

unit64 = Unit.create(
   id: 64,
   name: "As Entered",
   metric_ratio: "",
   unit_type: "other"
)

unit65 = Unit.create(
   id: 65,
   name: "Order",
   metric_ratio: "",
   unit_type: "other"
)

unit66 = Unit.create(
   id: 66,
   name: "Thick Slice",
   metric_ratio: "",
   unit_type: "other"
)

unit67 = Unit.create(
   id: 67,
   name: "Dry Serving",
   metric_ratio: "",
   unit_type: "other"
)

unit68 = Unit.create(
   id: 68,
   name: "Individual Package",
   metric_ratio: "",
   unit_type: "other"
)

unit69 = Unit.create(
   id: 69,
   name: "Bag",
   metric_ratio: "",
   unit_type: "other"
)

unit70 = Unit.create(
   id: 70,
   name: "Container",
   metric_ratio: "",
   unit_type: "other"
)

unit71 = Unit.create(
   id: 71,
   name: "Package",
   metric_ratio: "",
   unit_type: "other"
)

unit72 = Unit.create(
   id: 72,
   name: "Percent",
   metric_ratio: "",
   unit_type: "other"
)

unit73 = Unit.create(
   id: 73,
   name: "International Unit",
   metric_ratio: "",
   unit_type: "other"
)

unit74 = Unit.create(
   id: 74,
   name: "Calorie",
   metric_ratio: "",
   unit_type: "other"
)

unit75 = Unit.create(
   id: 75,
   name: "Retinol Equivalent",
   metric_ratio: "",
   unit_type: "other"
)

unit76 = Unit.create(
   id: 76,
   name: "Retinol Activity Equivalent",
   metric_ratio: "",
   unit_type: "other"
)

unit77 = Unit.create(
   id: 77,
   name: "Dietary Folate Equivalent",
   metric_ratio: "",
   unit_type: "other"
)

unit78 = Unit.create(
   id: 78,
   name: "Ounce Equivalent",
   metric_ratio: 28.35,
   unit_type: "mass"
)

unit79 = Unit.create(
   id: 79,
   name: "Cup Equivalent",
   metric_ratio: 284.131,
   unit_type: "volume"
)

99.times do |n|
  ## there are many portions to only a limited number of units
  ## so should portion belong to unit not the other way around?
  portion_obj = Portion.where(:unit => n).first_or_create
  unit_obj = Unit.where(:id => n).first_or_create
  portion_obj.units << unit_obj
end



c1 = Cupboard.create(location: "Fridge Door")
c2 = Cupboard.create(location: "Fridge Bottom Drawer")
c3 = Cupboard.create(location: "Fridge Top Shelf")
c4 = Cupboard.create(location: "Cupboard by the Oven")

### todo - setup some ingredients to be added to cupboard locations


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
