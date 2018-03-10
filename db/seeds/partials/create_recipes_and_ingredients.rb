recipes = RecipeVars.recipes
foodRegex = RecipeVars.foodRegex
recipeRegex = RecipeVars.recipeRegex
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


food_in_titles = ['Pork', 'Potato', 'Lamb', 'Duck', 'Bean', 'Chicken', 'Beef']

recipes.css('recipe').each_with_index do |recipe, recipe_index|

  recipe_title = recipe['description']
  recipe_desc = Array.new

  ### method to restructure recipe titles, adding a cuisine type for each recipe
  # recipe_title_edit = recipe_title.split(',')
  # if recipe_title_edit.length > 2
  #   cuisine_type = recipe_title_edit.last
  # end
  # if food_in_titles.include?(recipe_title_edit[0])
  #   ## build string with food still in title
  # end
  # if recipe_title.downcase.include?('vegetarian')
  # end


  recipe.children.css('XML_MEMO1').each do |description|
    recipe_desc << description.inner_text
  end

  recipe_desc = recipe_desc.join('').gsub(/#{recipeRegex}/, '')

	recipe_new = Recipe.create(title: recipe_title, description: recipe_desc.to_s)

	recipe.children.css('RecipeItem').each do |ingredient|

		## define ingredient
    ingredient_name = ingredient['ItemName']
    ingredient_unit = ingredient['itemMeasureKey'].to_s
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

    ingredient_obj = Ingredient.where(name: ingredient_name).first

    ## make sure we only use the first ingredient of a name in a recipe list (there are duplicates!)
    if not recipe_new.ingredients.include?(ingredient_obj)
      ## find the ingredient using its name
      ingredient_obj = Ingredient.where(name: ingredient_name).first
      
      ## add the ingredient to the recipe's ingredients
      recipe_new.ingredients << ingredient_obj

      ## find the portion for the recipe and ingredient ids
      portion_obj = Portion.where(recipe_id: recipe_new.id, ingredient_id: ingredient_obj.id).first
      
      ## catch the ingredients with units which already match a more common unit
      if ingredient_unit == '19' || ingredient_unit == '56' || ingredient_unit == '79'
        ## catch ingredients with units the same as ounces (unit3)
        unit_obj = Unit.find_or_create_by(unit_number: 3)  
      elsif ingredient_unit.to_s == '78'
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