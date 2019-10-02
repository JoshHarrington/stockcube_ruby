module IngredientsHelper

	def convert_serving_to_hash(serving)
		return serving if serving.class == Hash
		return {
			amount: (serving.amount ? serving.amount : nil),
			unit_type: (serving.unit && serving.unit.unit_type ? serving.unit.unit_type : nil),
			metric_ratio: (serving.unit && serving.unit.metric_ratio ? serving.unit.metric_ratio : nil)
		}
	end

	def convert_serving_array_to_array_of_hashes(serving_array)
		return false unless serving_array.length > 1
		processed_serving_array = []
		serving_array.map{|i| processed_serving_array.push(convert_serving_to_hash(i))}
		return false if processed_serving_array.select{|i| i[:unit_type] == nil || i[:metric_ratio] || i[:amount] == nil }.length > 0
	end


	def get_serving_unit_type(serving)
		if serving != Hash
			serving = convert_serving_to_hash(serving)
		end

		return serving[:unit_type]
	end

	def ingredient_metric_check(serving)
		return false unless (serving.class == Hash && serving.has_key?(:metric_ratio)) ||
			(serving.class != Hash && serving.unit && serving.unit.metric_ratio)
		return serving
	end

	def ingredient_unit_type_match(serving_array = [])
		processed_serving_array = convert_serving_array_to_array_of_hashes(serving_array)
		return false if processed_serving_array == false

		unit_types = processed_serving_array.map{|i| i[:unit_type]}.uniq
		return false if unit_types.length > 1

		return unit_types.first
	end

	def serving_converter(serving = nil)
		## serving means either stock or portion
		## or anything which has an ingredient association and an amount

		return false if serving == nil
		processed_serving = convert_serving_to_hash(serving)
		return false if (processed_serving[:unit_type] == nil || processed_serving[:amount] == nil || processed_serving[:metric_ratio] == nil)

		return {
			amount: processed_serving[:amount].to_f * processed_serving[:metric_ratio].to_f,
			metric_ratio: 1,
			unit_type: processed_serving[:unit_type]
		}

	end

	def serving_difference(serving_array = [])
		return false unless serving_array.length > 0
		return serving_array.first if serving_array.length == 1

		unit_type = ingredient_unit_type_match(serving_array)
		return false if unit_type == false

		processed_serving_array = convert_serving_array_to_array_of_hashes(serving_array)
		return false if processed_serving_array == false

		unit_types = processed_serving_array.map{|i| i[:unit_type]}.uniq
		return false if unit_types.length > 1

		processed_serving_array = processed_serving_array.map{|s| serving_converter(s)}
		processed_serving_array = processed_serving_array.sort{|a, b| a[:amount] <=> b[:amount]}.reverse

		serving_diff = processed_serving_array.first[:amount]
		processed_serving_array.each_with_index.map{|s, i| next if i == 0; serving_diff = serving_diff - s[:amount] }.compact

		return serving_diff

	end

	def serving_addition(serving_array = [])
		return false unless serving_array.length > 0

		unit_type = ingredient_unit_type_match(serving_array)
		return false if unit_type == false

		processed_serving_array = convert_serving_array_to_array_of_hashes(serving_array)
		return false if processed_serving_array == false

		unit_types = processed_serving_array.map{|i| i[:unit_type]}.uniq
		return false if unit_types.length > 1

		converted_serving_array = processed_serving_array.map{|s| serving_converter(s)}
		return {
			amount: converted_serving_array.select{|s| s.key?[:amount] && s[:amount] != nil}.sum{|s| s[:amount] },
			unit_type: processed_serving_array.first[:unit_type],
			metric_ratio: processed_serving_array.first[:metric_ratio]
		}

	end

	def default_unit_id(serving = nil)
		return unless serving != nil
		return unless ingredient_metric_check(serving) && get_serving_unit_type(serving)

		return Unit.find_by(unit_type: get_serving_unit_type(serving), metric_ratio: 1).id

	end


end
