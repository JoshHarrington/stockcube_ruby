module IngredientsHelper
	def get_ingredient_plus_unit_type(ingredient_plus)
		if ingredient_plus.class == Hash && ingredient_plus.has_key?(:unit_type)
			return ingredient_plus[:unit_type]
		elsif ingredient_plus.class != Hash && ingredient_plus.unit && ingredient_plus.unit.unit_type
			return ingredient_plus.unit.unit_type
		else
			return false
		end
	end

	def ingredient_metric_check(ingredient_plus)
		return false unless (ingredient_plus.class == Hash && ingredient_plus.has_key?(:unit_metric_ratio)) ||
			(ingredient_plus.class != Hash && ingredient_plus.unit && ingredient_plus.unit.metric_ratio)
		return ingredient_plus
	end

	def ingredient_unit_type_match(ingredient_plus_1, ingredient_plus_2)
		# return false unless get_ingredient_plus_unit_type(ingredient_plus_1) && get_ingredient_plus_unit_type(ingredient_plus_2)
		return false unless get_ingredient_plus_unit_type(ingredient_plus_1) == get_ingredient_plus_unit_type(ingredient_plus_2)
	end

	def ingredient_plus_converter(ingredient_plus = nil)
		## ingredient_plus means either stock or portion
		## or anything which has an ingredient association and an amount

		return false unless ingredient_plus != nil &&
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

		if ingredient_plus_1.unit_id == ingredient_plus_2.unit_id
			return ingredient_plus_1.amount - ingredient_plus_2.amount
		elsif ingredient_unit_type_match(ingredient_plus_1, ingredient_plus_2) && ingredient_metric_check(ingredient_plus_1) && ingredient_metric_check(ingredient_plus_2)
			return ingredient_plus_converter(ingredient_plus_1) - ingredient_plus_converter(ingredient_plus_2)
		else
			return false
		end
	end

	def ingredient_plus_addition(ingredient_plus_array = [])
		return false if ingredient_plus_array.length == 0 || ingredient_plus_array.class != Array

		sum_ingredient_plus = 0
		unit_id = nil

		ingredient_plus_array.each_with_index do |ingredient_plus, index|
			if ingredient_plus.unit_id == ingredient_plus_array[0].unit_id
				sum_ingredient_plus += ingredient_plus.amount
				unit_id = ingredient_plus_array[0].unit_id
			elsif ingredient_metric_check(ingredient_plus_array[0]) && ingredient_metric_check(ingredient_plus) &&
				ingredient_unit_type_match(ingredient_plus_array[0], ingredient_plus)
				sum_ingredient_plus += ingredient_plus_converter(ingredient_plus)
				unit_id = default_unit_id(ingredient_plus_array[0])
			else
				next
			end
		end

		if sum_ingredient_plus == 0
			return false
		else
			return {amount: sum_ingredient_plus, unit_id: unit_id}
		end

	end

	def default_unit_id(ingredient_plus = nil)
		return unless ingredient_plus != nil
		return unless ingredient_metric_check(ingredient_plus) && get_ingredient_plus_unit_type(ingredient_plus)

		return Unit.find_by(unit_type: get_ingredient_plus_unit_type(ingredient_plus), metric_ratio: 1).id

	end


end
