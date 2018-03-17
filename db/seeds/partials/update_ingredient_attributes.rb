if Rails.env.downcase == "production"
  veggieRecipesXML = File.read("./db/foodDBs/VegetarianRecipes.exl")
  worldRecipesXML = File.read("./db/foodDBs/WorldRecipes.exl")

  veggieRecipes = Nokogiri::XML(veggieRecipesXML)
  worldRecipes = Nokogiri::XML(worldRecipesXML).search('data')

  RecipeVars.recipes = veggieRecipes.at('data').add_child(worldRecipes)

  RecipeVars.foodRegex = "(, boiled.*)|(, blanched.*)|(, california.*)|(, pan fried.*)|(, braised.*)|(, roasted.*)|(, chuck clod.*)|(, fresh.*)|(, salad or.*)|(, instant.*)|(, prepared.*)|(, sliced.*)|(, canned.*)|(, salted.*)|(, dry roasted.*)|(, plain.*)|(, double acting.*)|(, Eagle.*)|(, from .*)|(, degerminated.*)|(, ground.*)|(, all purpose.*)|(, pastry.*)|(, white.*)|(, cooked.*)|(, grated.*)|(, shredded.*)|(, organic.*)|(, dash.*)|(, whole grain.*)|(, chopped.*)|(, extracted.*)|(, unsweetened.*)|(, frozen.*)|(, red, California.*)|(, old fashioned.*)|(, dry.*)|(, original.*)|(, TSP.*)|(, seedless.*)|(, without seeds.*)|(, table.*)|(, brown.*)|(, with calcium.*)|(, winter.*)|(, powdered.*)|(, silken.*)|(, with nigari.*)|(, unsalted.*)|(, crushed.*)|(, stewed.*)|(, filtered.*)|(, natural.*)|(, municipal.*)|(, regular.*)|(, baked.*)|(, active.*)|(, steamed.*)|(, ready to.*)|(, diced.*)|(, powder.*)|(, defatted.*)|(, toasted.*)|(, hulled.*)|(, oriental.*)|(, daikon.*)|(, halves.*)|(, creamy.*)|(, flakes.*)|(, vital.*)|(, slivered.*)|(, 60 grain.*)|(, raw.*)|(, top round.*)|(, top sirloin.*)|(, chuck.*)|(, dehydrated.*)|(, seasoned.*)|(, low moisture.*)|(, roasted.*)|(, whole.*)|(, kernels.*)|(, 50 grain.*)|(, refrigerated.*)|(, smoked.*)|(, food service.*)|(, elegant.*)|(, chilled.*)"
  RecipeVars.recipeRegex = "(Copyright.*)|(www\..*\n.*\n.*)"
end

recipes = RecipeVars.recipes
foodRegex = RecipeVars.foodRegex
recipeRegex = RecipeVars.recipeRegex


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
