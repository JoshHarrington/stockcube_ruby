module ServingHelper
	include IntegerHelper
	def serving_unit_convert(amount, unit)
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

		unit_name = updated_serving[:unit][:name]
		amount = updated_serving[:amount]

		if unit_name.downcase == 'each'
			return amount.to_s + ' ' + (serving.ingredient.name.to_s).pluralize(amount)
		elsif unit_name.downcase == 'small' || unit_name.downcase == 'medium' || unit_name.downcase == 'large'
			return amount.to_s + ' ' + unit_name + ' ' + (serving.ingredient.name.to_s).pluralize(amount)
		else
			return amount.to_s + ' ' + (unit_name).pluralize(amount) + ' ' + serving.ingredient.name.to_s
		end
	end

	def short_serving_description(serving)
		updated_serving = serving_unit_convert(serving.amount, serving.unit)

		unit_name = updated_serving[:unit][:short_name]
		amount = updated_serving[:amount]

		if unit_name.downcase == 'each'
			return amount.to_s + ' ' + (serving.ingredient.name.to_s).pluralize(amount)
		elsif unit_name.downcase == 'small' || unit_name.downcase == 'medium' || unit_name.downcase == 'large'
			return amount.to_s + ' ' + unit_name + ' ' + (serving.ingredient.name.to_s).pluralize(amount)
		else
			return amount.to_s + unit_name + ' ' + serving.ingredient.name.to_s
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
