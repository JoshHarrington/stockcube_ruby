module RecipesHelper
	def recipe_description
		description = @recipe.description
		description.gsub!(/\n/, '<br />')
	end
	def vegan?(recipe)
		if recipe.ingredients.none?{ |ingredient| ingredient.vegan == false }
			return true
		end
	end
	def vegetarian?(recipe)
		if recipe.ingredients.none?{ |ingredient| ingredient.vegetarian == false }
			return true
		end
	end
	def gluten_free?(recipe)
		if recipe.ingredients.none?{ |ingredient| ingredient.gluten_free == false }
			return true
		end
	end
	def dairy_free?(recipe)
		if recipe.ingredients.none?{ |ingredient| ingredient.dairy_free == false }
			return true
		end
	end
	def kosher?(recipe)
		if recipe.ingredients.none?{ |ingredient| ingredient.kosher == false }
			return true
		end
	end
	def portion_amount_unit_and_ingredient(portion)

		## check if ingredient unit is correct unit, fallback to portion unit if different
		if portion.unit_number == portion.ingredient.unit_id
			if portion.ingredient.unit.short_name
				portion_unit = portion.ingredient.unit.short_name.downcase
			else
				portion_unit = portion.ingredient.unit.name
			end
		else
			correct_unit = Unit.where(unit_number: portion.unit_number).first
			if correct_unit.short_name
				portion_unit = correct_unit.short_name.downcase
			else
				portion_unit = correct_unit.name
			end
		end

		portion_amount = portion.amount
		ingredient = portion.ingredient.name

		if portion_amount == 0.33
			portion_amount = 1/3.to_r
		elsif portion_amount == 0.67
			portion_amount = 2/3.to_r
		end

		if (portion_amount.to_f % 1 == 0)
			portion_amount = portion_amount.to_i
		elsif (portion_amount.to_r > 1)
			# portion_amount = portion.amount.to_r
			portion_amount = portion_amount.to_r.to_whole_fraction
			portion_amount = portion_amount[0].to_s + " <sup>" + portion_amount[1].to_s + "</sup>/<sub>" + portion_amount[2].to_s + "</sub>"
		else
			portion_amount = portion_amount.to_r.to_s
			portion_amount = portion_amount.split('/')
			portion_amount = " <sup>" + portion_amount[0].to_s + "</sup>/<sub>" + portion_amount[1].to_s + "</sub>"
		end


		if portion_unit == "Each"
			## figure out pluralization at same time, based on portion amount
			portion_amount.to_s + ' ' + ingredient.pluralize(portion_amount.to_i)
		else
			if portion.ingredient.unit.short_name
				if portion_unit.include?("m") || portion_unit.include?("g") || portion_unit.include?("g")
					portion_amount.to_s + portion_unit.to_s + ' ' + ingredient.to_s
				else
					portion_amount.to_s + ' ' + portion_unit.to_s + ' ' + ingredient.to_s
				end
			else
				portion_unit = portion_unit.pluralize(portion_amount.to_i)
				portion_amount.to_s + ' ' + portion_unit.to_s + ' ' + ingredient.to_s
			end
		end
	end
end
