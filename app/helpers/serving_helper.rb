module ServingHelper
	include IntegerHelper
	def standard_serving_description(serving)
		unit_name = serving.unit.name
		amount = round_if_whole(serving.amount)
		if serving.unit.metric_ratio == 1 && serving.amount >= 1000
			if serving.unit.unit_type.downcase.to_s == "volume"
				unit_name = "litre"
				amount = round_if_whole(serving.amount / 1000)
			elsif serving.unit.unit_type.downcase.to_s == "mass"
				unit_name = "kilogram"
				amount = round_if_whole(serving.amount / 1000)
			end
		end

		if unit_name.downcase == 'each'
			return round_if_whole(amount).to_s + ' ' + (serving.ingredient.name.to_s).pluralize(amount)
		elsif unit_name.downcase == 'small' || unit_name.downcase == 'medium' || unit_name.downcase == 'large'
			return round_if_whole(amount).to_s + ' ' + unit_name + ' ' + (serving.ingredient.name.to_s).pluralize(amount)
		else
			return round_if_whole(amount).to_s + ' ' + (unit_name).pluralize(amount) + ' ' + serving.ingredient.name.to_s
		end
	end

	def standard_serving_size(serving)
		unit_name = serving.unit.name
		amount = round_if_whole(serving.amount)
		if serving.unit.metric_ratio == 1 && serving.amount >= 1000
			if serving.unit.unit_type.downcase.to_s == "volume"
				unit_name = "litre"
				amount = round_if_whole(serving.amount / 1000)
			elsif serving.unit.unit_type.downcase.to_s == "mass"
				unit_name = "kilogram"
				amount = round_if_whole(serving.amount / 1000)
			end
		end

		if unit_name.downcase == 'each'
			return round_if_whole(amount).to_s
		elsif unit_name.downcase == 'small' || unit_name.downcase == 'medium' || unit_name.downcase == 'large'
			return round_if_whole(amount).to_s + ' ' + unit_name
		else
			return round_if_whole(amount).to_s + ' ' + (unit_name).pluralize(amount)
		end
	end
end
