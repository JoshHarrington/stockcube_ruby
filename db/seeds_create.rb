require 'nokogiri'
require 'set'
require 'uri'

## units

### need to create unit table entries based on this data

1, "Teaspoon", 5, "mass"
2, "Tablespoon", 15, "mass"
3, "Cup", 284.131, "volume"
4, "Piece", "", "other"
5, "Each", "", "other"
6, "Ounce-weight", 28.35, "mass"
7, "Pound", 500, "mass"
8, "Gram", 1, "mass"
9, "Kilogram", 1000, "mass"
10, "Fluid ounce", 28.4131, "volume"
11, "Milliliter", 1, "volume"
12, "Liter", 1000, "volume"
13, "Gallon", 3785.4118, "volume"
14, "Pint", 568.26125, "volume"
15, "Quart", 1136.52, "volume"
16, "Milligram", 0.001, "mass"
17, "Microgram", 0.000001, "mass"
18, "Intake", "", "other"
19, "Individual Cup", 284.131, "volume"
20, "Bottle", "", "other"
21, "Box", "", "other"
22, "Can", "", "other"
23, "Individual Bag", "", "other"
24, "Cube", "", "other"
25, "Jar", "", "other"
26, "Stick", "", "other"
27, "Tablet", "", "other"
28, "Bowl", "", "other"
29, "Meal", "", "other"
30, "Slice", "", "other"
31, "Serving", "", "other"
32, "300 Can", 414.0294, "volume"
33, "303 Can", 473.176, "volume"
34, "401 Can", 828.059, "volume"
35, "404 Can", 1360.382, "volume"
36, "Individual Packet", "", "other"
37, "Scoop", "", "other"
38, "Regular", "", "other"
39, "Small", "", "other"
40, "Medium", "", "other"
41, "Large", "", "other"
42, "Extra Large", "", "other"
43, "Individual", "", "other"
44, "Side", "", "other"
45, "Appetizer", "", "other"
46, "Entree", "", "other"
47, "Capsule", "", "other"
48, "Kids'", "", "other"
49, "Whole", "", "other"
50, "Pat", "", "other"
51, "Pouch", "", "other"
52, "Drop", "", "other"
53, "Jumbo", "", "other"
54, "Second Spray", "", "other"
55, "Topping", "", "other"
56, "Portion Cup", 284.131, "volume"
57, "Caplet", "", "other"
58, "Mini", "", "other"
59, "Cubic Inch", 16.3871, "volume"
60, "Thin Slice", "", "other"
61, "Sheet", "", "other"
62, "Family", "", "other"
63, "#10 Can", 3409.5675, "volume"
64, "As Entered", "", "other"
65, "Order", "", "other"
66, "Thick Slice", "", "other"
67, "Dry Serving", "", "other"
68, "Individual Package", "", "other"
69, "Bag", "", "other"
70, "Container", "", "other"
71, "Package", "", "other"
72, "Percent", "", "other"
73, "International Unit", "", "other"
74, "Calorie", "", "other"
75, "Retinol Equivalent", "", "other"
76, "Retinol Activity Equivalent", "", "other"
77, "Dietary Folate Equivalent", "", "other"
78, "Ounce Equivalent", 28.35, "mass"
79, "Cup Equivalent", 284.131, "volume"


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
    ingredient_portion = ingredient['itemQuantity']
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

# Build recipe selection
recipes = Recipe.all
recipe  = recipes.first
recipePickTitle  = recipes[2].title
recipePickObj = Recipe.find_or_create_by(title: recipePickTitle)

me.recipes << recipePickObj