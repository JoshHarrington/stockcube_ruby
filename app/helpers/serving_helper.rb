module ServingHelper
	include IntegerHelper
	include CupboardHelper

	include PortionStockHelper
	include IngredientsHelper

	def serving_unit_convert(amount = nil, unit = nil)
		return if amount == nil || unit == nil

		if unit.metric_ratio == 1 && amount >= 1000
			if unit.unit_type.downcase.to_s == "volume"
				return {
					unit: {
						name: "litre",
						short_name: "l"
					},
					amount: round_if_whole(amount / 1000)
				}
			elsif unit.unit_type.downcase.to_s == "mass"
				return {
					unit: {
						name: "kilogram",
						short_name: "kg"
					},
					amount: round_if_whole(amount / 1000)
				}
			end
		else
			return {
				unit: unit,
				amount: round_if_whole(amount)
			}
		end
	end

	def short_serving_size(serving = nil)
		return if serving == nil

		if serving.class == Hash
			unit = serving.has_key?(:unit) ? serving[:unit] : nil
			serving_amount = serving[:amount]
		else
			unit = serving.unit
			serving_amount = serving.amount
		end

		stock = nil
		if serving.class == PlannerShoppingListPortion
			if serving.class == Hash
				stock = serving[:stock]
			else
				stock = serving.stock
			end
		end

		serving_numeric_string = ''
		if stock != nil && percentage_of_portion_in_stock(stock) < 95
			serving_numeric_string = round_if_whole(stock.amount).to_s + ' of ' + round_if_whole(serving_amount).to_s
		else
			serving_numeric_string = round_if_whole(serving_amount).to_s
		end

		unit_name = unit ? unit.name : nil
		unit_short_name = unit && unit.short_name ? unit.short_name : nil

		if unit != nil
			if unit_name.downcase == 'each'
				return serving_numeric_string
			elsif unit_name.downcase == 'small' || unit_name.downcase == 'medium' || unit_name.downcase == 'large'
				return serving_numeric_string + ' ' + unit_name
			else
				return serving_numeric_string + (unit_short_name != nil ? unit_short_name : " " + unit_name.to_s).pluralize(serving_amount)
			end
		end
	end

	def serving_description(serving = nil)
		return if serving == nil

		if serving.class == Hash
			unit = serving.has_key?(:unit) ? serving[:unit] : nil
			serving_amount = serving[:amount]
		else
			unit = serving.unit
			serving_amount = serving.amount
		end

		if serving.class == CombiPlannerShoppingListPortion && unit == nil && serving_amount == nil
			return combi_serving_description(serving)
		end

		unit_name = unit != nil ? unit.name : nil

		if unit_name != nil && serving_amount != nil

			if unit_name == "each"
				return short_serving_size(serving) + ' ' + (serving.ingredient.name.to_s).pluralize(serving_amount)
			elsif unit_name.downcase == 'small' || unit_name.downcase == 'medium' || unit_name.downcase == 'large'
				return short_serving_size(serving) + ' ' + (serving.ingredient.name.to_s).pluralize(serving_amount)
			else
				return short_serving_size(serving) + ' ' + serving.ingredient.name.to_s
			end

		end
	end


	def upscale_serving(serving = nil)
		return if serving == nil

		processed_serving = serving_converter(serving)

		upscaled_serving = nil
		if processed_serving[:unit].metric_ratio == 1 && processed_serving[:amount] > 999
			if processed_serving[:unit].unit_type == "Mass"
				kg_unit = Unit.find_or_create_by(
					name: "kilogram",
					short_name: "kg",
					unit_type: "Mass",
					metric_ratio: 1000
				)
				upscaled_serving = convert_to_different_unit(processed_serving, kg_unit)
			elsif processed_serving[:unit].unit_type == "Volume"
				litre_unit = Unit.find_or_create_by(
					name: "litre",
					short_name: "l",
					unit_type: "Volume",
					metric_ratio: 1000
				)
				upscaled_serving = convert_to_different_unit(processed_serving, litre_unit)
			end
		end

		return upscaled_serving != nil ? upscaled_serving : processed_serving
	end

	def combi_serving_description(combi_portion = nil)
		return if combi_portion == nil

		if combi_portion.planner_shopping_list_portions.select{|p|p.checked == false}.length > 0

			needed_stock = list_grouped_stock(combi_portion.planner_shopping_list_portions, true)

			combi_serving_portions_formatted = needed_stock.compact.select{|p|p[:amount] != 0}

			combi_portions_list = combi_serving_portions_formatted.map{|p| stock_needed_serving_size(upscale_serving(p)) }

			ingredient_name = combi_portion.ingredient.name
			if combi_serving_portions_formatted.length == 1
				ingredient_name = combi_portion.ingredient.name.pluralize(serving_converter(combi_serving_portions_formatted.first)[:amount])
			end

			return combi_portions_list.join(" + ").to_s + ' ' + ingredient_name
		elsif combi_portion.planner_shopping_list_portions.length > 0

			combi_serving_portions_formatted = list_grouped_stock(combi_portion.planner_shopping_list_portions, false).compact
			combi_portions_list = combi_serving_portions_formatted.map{|p| stock_needed_serving_size(upscale_serving(p)) }

			ingredient_name = combi_portion.ingredient.name
			if combi_serving_portions_formatted.length == 1
				ingredient_name = combi_portion.ingredient.name.pluralize(serving_converter(combi_serving_portions_formatted.first)[:amount])
			end

			return combi_portions_list.join(" + ").to_s + ' ' + ingredient_name

		end
	end


	def stock_needed_serving_size(serving = nil)
		return if serving == nil || serving.class == Array

		if serving.class == Hash
			unit = serving.has_key?(:unit) ? serving[:unit] : nil
			serving_amount = serving[:amount]
		else
			unit = serving.unit
			serving_amount = serving.amount
		end

		stock = nil
		if serving.class == PlannerShoppingListPortion
			if serving.class == Hash
				stock = serving[:stock]
			else
				stock = serving.stock
			end
		end

		serving_numeric_string = ''
		if stock != nil && percentage_of_portion_in_stock(stock) < 95
			serving_numeric_string = round_if_whole(serving_amount - stock.amount).to_s
		else
			serving_numeric_string = round_if_whole(serving_amount).to_s
		end

		if unit != nil && serving_amount != nil

			unit_name = unit.name
			unit_short_name = unit.short_name

			if unit_name.downcase == 'each'
				return serving_numeric_string
			elsif unit_name.downcase == 'small' || unit_name.downcase == 'medium' || unit_name.downcase == 'large'
				return serving_numeric_string + ' ' + unit_name
			else
				return serving_numeric_string + (unit_short_name != nil ? unit_short_name : " " + unit_name.to_s).pluralize(serving_amount)
			end
		end
	end

	def stock_needed_serving_description(serving = nil)
		return if serving == nil

		if serving.class == Hash
			unit = serving[:unit]
			serving_amount = serving[:amount]
		else
			unit = serving.unit
			serving_amount = serving.amount
		end

		if serving.class == CombiPlannerShoppingListPortion
			return combi_serving_description(serving)
		end

		unit_name = unit != nil ? unit.name : nil

		if unit_name != nil && serving_amount != nil

			# case unit_name
			if unit_name == "each"
				return stock_needed_serving_size(serving) + ' ' + (serving.ingredient.name.to_s).pluralize(serving_amount)
			elsif unit_name.downcase == 'small' || unit_name.downcase == 'medium' || unit_name.downcase == 'large'
				return stock_needed_serving_size(serving) + ' ' + (serving.ingredient.name.to_s).pluralize(serving_amount)
			else
				return stock_needed_serving_size(serving) + ' ' + serving.ingredient.name.to_s
			end

		end
	end

end
