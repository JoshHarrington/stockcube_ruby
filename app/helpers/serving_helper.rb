module ServingHelper
	include IntegerHelper
	include CupboardHelper

	include PortionStockHelper

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

	def standard_serving_description(serving)

		updated_serving = serving_unit_convert(serving.amount, serving.unit)

		unit_name = updated_serving != nil ? updated_serving[:unit][:name] : nil
		amount = updated_serving != nil ? updated_serving[:amount] : nil

		if unit_name != nil && amount != nil

			if unit_name.downcase == 'each'
				return amount.to_s + ' ' + (serving.ingredient.name.to_s).pluralize(amount)
			elsif unit_name.downcase == 'small' || unit_name.downcase == 'medium' || unit_name.downcase == 'large'
				return amount.to_s + ' ' + unit_name + ' ' + (serving.ingredient.name.to_s).pluralize(amount)
			else
				return amount.to_s + ' ' + (unit_name).pluralize(amount) + ' ' + serving.ingredient.name.to_s
			end
		else
			return "standard_serving_description no unit_name && no amount"
		end
	end

	def short_serving_description(serving, portion = nil)
		updated_serving = serving_unit_convert(serving.amount, serving.unit)

		unit_short_name = updated_serving != nil ? updated_serving[:unit][:short_name] : nil
		amount = updated_serving != nil ? updated_serving[:amount] : nil

		if unit_short_name == nil
			standard_serving_description(serving)
		elsif amount != nil


			total_serving_size = ''
			if portion != nil && percentage_of_portion_in_stock(serving) < 95
				total_serving_size = ' of ' + round_if_whole(portion.amount).to_s
			end

			if unit_short_name.downcase == 'each'
				return amount.to_s + total_serving_size + ' ' + (serving.ingredient.name.to_s).pluralize(amount)
			elsif unit_short_name.downcase == 'small' || unit_short_name.downcase == 'medium' || unit_short_name.downcase == 'large'
				return amount.to_s + total_serving_size + ' ' + unit_short_name + ' ' + (serving.ingredient.name.to_s).pluralize(amount)
			else
				return amount.to_s + total_serving_size + unit_short_name + ' ' + serving.ingredient.name.to_s
			end
		else
			return "short_serving_description no unit_name && no amount"
		end

	end

	def combi_serving_description(combi_portion = nil)
		return if combi_portion == nil
		if combi_portion.amount != nil && combi_portion.unit_id != nil
			short_serving_description(combi_portion)
		else
			return combi_portion.planner_shopping_list_portions.map{|p|
				standard_serving_size(p)
			}.join(" + ").to_s + ' ' + combi_portion.ingredient.name
		end
	end

	def standard_serving_size(serving)
		updated_serving = serving_unit_convert(serving.amount, serving.unit)

		unit_name = updated_serving[:unit][:name]
		amount = updated_serving[:amount]

		if unit_name.downcase == 'each'
			return amount.to_s
		elsif unit_name.downcase == 'small' || unit_name.downcase == 'medium' || unit_name.downcase == 'large'
			return amount.to_s + ' ' + unit_name
		else
			return amount.to_s + ' ' + (unit_name).pluralize(amount)
		end
	end
end
