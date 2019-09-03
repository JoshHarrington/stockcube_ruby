module IngredientsHelper
	def ingredient_health_check(ingredient_plus)
		if (ingredient_plus.class == Hash && ingredient_plus.has_key?(:unit_metric_ratio)) ||
			(ingredient_plus.class != Hash && ingredient_plus.unit && ingredient_plus.unit.metric_ratio)
			return ingredient_plus
		else
			return false
		end
	end

	def ingredient_plus_converter(ingredient_plus = nil)
		## ingredient_plus means either stock or portion
		## or anything which has an ingredient association and an amount

		return unless ingredient_plus != nil &&
			(ingredient_plus.class == Hash && ingredient_plus.has_key?(:unit_metric_ratio) &&
			ingredient_plus.has_key?(:unit_type) && ingredient_plus.has_key?(:amount)) ||
			(ingredient_plus.class != Hash && ingredient_plus.unit && ingredient_plus.unit.metric_ratio &&
			ingredient_plus.unit.unit_type)

		if ingredient_plus.class != Hash
			if ingredient_plus.unit.unit_type == 'mass' || ingredient_plus.unit.unit_type == 'volume'
				return ingredient_plus.amount * ingredient_plus.unit.metric_ratio
			end
		elsif ingredient_plus.class == Hash
			if ingredient_plus[:unit_type] == 'mass' || ingredient_plus[:unit_type] == 'volume'
				return ingredient_plus[:amount] * ingredient_plus[:unit_metric_ratio]
			end
		end
	end

	def ingredient_plus_difference(ingredient_plus_1 = nil, ingredient_plus_2 = nil)
		if ingredient_health_check(ingredient_plus_1) && ingredient_health_check(ingredient_plus_2)
			return ingredient_plus_converter(ingredient_plus_1) - ingredient_plus_converter(ingredient_plus_2)
		else
			return false
		end

	end

	def ingredient_plus_addition(ingredient_plus_1 = nil, ingredient_plus_2 = nil)
		return ingredient_plus_converter(ingredient_plus_1) + ingredient_plus_converter(ingredient_plus_2)
	end

	def default_unit_id(ingredient_plus = nil)
		return unless ingredient_plus != nil &&
		(ingredient_plus.class == Hash && ingredient_plus.has_key?(:unit_metric_ratio) &&
		ingredient_plus.has_key?(:unit_type) && ingredient_plus.has_key?(:amount)) ||
		(ingredient_plus.class != Hash && ingredient_plus.unit && ingredient_plus.unit.metric_ratio &&
		ingredient_plus.unit.unit_type)

		if (ingredient_plus.class != Hash && ingredient_plus.unit.unit_type == 'mass') || (ingredient_plus.class == Hash && ingredient_plus[:unit_type] == 'mass')
			return Unit.find_by(unit_type: 'mass', metric_ratio: 1).id
		elsif (ingredient_plus.class != Hash && ingredient_plus.unit.unit_type == 'volume') || (ingredient_plus.class == Hash && ingredient_plus[:unit_type] == 'volume')
			return Unit.find_by(unit_type: 'volume', metric_ratio: 1).id
		end

	end

	# def combine_ingredient_plus(ingredient_plus_1 = nil, ingredient_plus_2 = nil)
	# 	return unless ingredient_plus_1 != nil && ingredient_plus_2 != nil
	# end

end
