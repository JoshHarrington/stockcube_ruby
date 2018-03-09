module RecipeVars
	def RecipeVars.recipes
		veggieRecipesXML = File.read("./db/foodDBs/VegetarianRecipes.exl")
		worldRecipesXML = File.read("./db/foodDBs/WorldRecipes.exl")
		
		veggieRecipes = Nokogiri::XML(veggieRecipesXML)
		worldRecipes = Nokogiri::XML(worldRecipesXML).search('data')

		veggieRecipes.at('data').add_child(worldRecipes)
	end
	def RecipeVars.foodRegex
		"(, boiled.*)|(, blanched.*)|(, california.*)|(, pan fried.*)|(, braised.*)|(, roasted.*)|(, chuck clod.*)|(, fresh.*)|(, salad or.*)|(, instant.*)|(, prepared.*)|(, sliced.*)|(, canned.*)|(, salted.*)|(, dry roasted.*)|(, plain.*)|(, double acting.*)|(, Eagle.*)|(, from .*)|(, degerminated.*)|(, ground.*)|(, all purpose.*)|(, pastry.*)|(, white.*)|(, cooked.*)|(, grated.*)|(, shredded.*)|(, organic.*)|(, dash.*)|(, whole grain.*)|(, chopped.*)|(, extracted.*)|(, unsweetened.*)|(, frozen.*)|(, red, California.*)|(, old fashioned.*)|(, dry.*)|(, original.*)|(, TSP.*)|(, seedless.*)|(, without seeds.*)|(, table.*)|(, brown.*)|(, with calcium.*)|(, winter.*)|(, powdered.*)|(, silken.*)|(, with nigari.*)|(, unsalted.*)|(, crushed.*)|(, stewed.*)|(, filtered.*)|(, natural.*)|(, municipal.*)|(, regular.*)|(, baked.*)|(, active.*)|(, steamed.*)|(, ready to.*)|(, diced.*)|(, powder.*)|(, defatted.*)|(, toasted.*)|(, hulled.*)|(, oriental.*)|(, daikon.*)|(, halves.*)|(, creamy.*)|(, flakes.*)|(, vital.*)|(, slivered.*)|(, 60 grain.*)|(, raw.*)|(, top round.*)|(, top sirloin.*)|(, chuck.*)|(, dehydrated.*)|(, seasoned.*)|(, low moisture.*)|(, roasted.*)|(, whole.*)|(, kernels.*)|(, 50 grain.*)|(, refrigerated.*)|(, smoked.*)|(, food service.*)|(, elegant.*)|(, chilled.*)"
	end
	def RecipeVars.recipeRegex
		"(Copyright.*)|(www\..*)"
	end
end
