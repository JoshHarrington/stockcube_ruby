module IngredientsHelper

	def convert_serving_to_hash(serving = nil)
		return if serving == nil
		return serving if serving.class == Hash
		return {
			amount: serving.amount ? serving.amount.to_f : nil,
			unit: serving.unit
		}
	end

	def convert_serving_array_to_array_of_hashes(serving_array)
		return convert_serving_to_hash(serving_array.first) if serving_array.length == 1
		return false unless serving_array.length > 1
		processed_serving_array = []
		serving_array.map{|i| processed_serving_array.push(convert_serving_to_hash(i))}
		return false if processed_serving_array.select{|i| i[:unit] == nil || i[:amount] == nil }.length > 0
		return processed_serving_array
	end

	def convert_to_different_unit(serving = nil, unit_to_convert_to = nil)
		return if serving == nil || unit_to_convert_to == nil

		processed_serving = convert_serving_to_hash(serving)
		return if processed_serving[:unit] == nil || processed_serving[:amount] == nil

		return {
			amount: processed_serving[:amount] / unit_to_convert_to.metric_ratio,
			unit: unit_to_convert_to
		}
	end


	def get_serving_unit_type(serving)
		if serving.class != Hash
			serving = convert_serving_to_hash(serving)
		end

		return serving[:unit].unit_type
	end

	def ingredient_metric_check(serving)
		if serving.class != Hash
			serving = convert_serving_to_hash(serving)
		end

		return false if serving[:unit].metric_ratio == nil
		return serving
	end

	def ingredient_unit_type_match(serving_array = [])
		processed_serving_array = convert_serving_array_to_array_of_hashes(serving_array)
		return false if processed_serving_array == false

		unit_types = processed_serving_array.map{|i| i[:unit].unit_type}.uniq
		return false if unit_types.length > 1

		return unit_types.first
	end

	def serving_converter(serving = nil)
		## serving means either stock or portion
		## or anything which has an ingredient association and an amount

		return false if serving == nil
		processed_serving = convert_serving_to_hash(serving)
		return false if (processed_serving[:unit] == nil || processed_serving[:amount] == nil)

		if processed_serving[:unit].unit_type != nil
			return {
				amount: processed_serving[:amount].to_f * processed_serving[:unit].metric_ratio.to_f,
				unit: default_unit(processed_serving)
			}
		else
			return processed_serving
		end

	end

	def serving_difference(serving_array = [])

		return serving_converter(serving_array.first) if serving_array.length == 1
		return false unless serving_array.length > 1

		### the order in this array matters so can't take more than two servings
		### the first serving will be what the other serving amount gets taken from
		return false if serving_array.length > 2

		unit_type = ingredient_unit_type_match(serving_array)
		return false if unit_type == false

		processed_serving_array = convert_serving_array_to_array_of_hashes(serving_array)
		return false if processed_serving_array == false

		unit_types = processed_serving_array.map{|i| i[:unit].unit_type}.uniq
		return false if unit_types.length > 1

		processed_serving_array = processed_serving_array.map{|s| serving_converter(s)}
		# processed_serving_array = processed_serving_array.sort{|a, b| a[:amount] <=> b[:amount]}.reverse

		serving_diff_amount = processed_serving_array.first[:amount]
		processed_serving_array.each_with_index.map{|s, i| next if i == 0; serving_diff_amount = serving_diff_amount - s[:amount] }.compact

		serving_diff = processed_serving_array.first
		serving_diff[:amount] = serving_diff_amount

		return serving_diff

	end

	def serving_addition(serving_array = [])
		return serving_converter(serving_array.first) if serving_array.length == 1
		return false unless serving_array.length > 1

		unit_type = ingredient_unit_type_match(serving_array)
		return false if unit_type == false

		processed_serving_array = convert_serving_array_to_array_of_hashes(serving_array)
		return false if processed_serving_array == false

		unit_types = processed_serving_array.map{|i| i[:unit].unit_type}.uniq
		return false if unit_types.length > 1

		unit_ids = processed_serving_array.map{|i| i[:unit]}.uniq
		if unit_ids.length > 1
			processed_serving_array = processed_serving_array.map{|s| serving_converter(s)}
		end

		return {
			amount: processed_serving_array.select{|s| s.key?(:amount) && s[:amount] != nil}.sum{|s| s[:amount] },
			unit: processed_serving_array.first[:unit]
		}

	end

	def default_unit(serving = nil)
		return unless serving != nil
		return unless ingredient_metric_check(serving) || get_serving_unit_type(serving)

		return Unit.find_by(unit_type: get_serving_unit_type(serving), metric_ratio: 1)
	end

	def default_unit_id(serving = nil)
		return unless serving != nil

		return default_unit(serving).id

	end

	def find_planner_portion_size(serving = nil)
		return unless serving != nil

		converted_sizes = []
		sizes = serving.ingredient.default_ingredient_sizes
		return false if sizes.length == 0
		sizes.map{|s| converted_sizes.push(convert_serving_to_hash(s))}
		converted_serving = convert_serving_to_hash(serving)

		return false if ingredient_unit_type_match([converted_serving, converted_sizes.first]) == false


		100.times.each_with_index do |i, index|
			next if index == 0
			sizes.each do |s|
				converted_size = convert_serving_to_hash(s)
				converted_size[:amount] = converted_size[:amount] * index
				size_diff = serving_difference([converted_size, converted_serving])
				if size_diff != false && size_diff[:amount] >= 0
					return {
						original_ingredient_size: s,
						converted_size: converted_size
					}
				end

			end
		end

	end

	def get_ingredient_use_by_date_diff(ing = nil)
		return 14 if ing == nil

		if ing.default_ingredient_sizes && ing.default_ingredient_sizes.length > 0
			return ing.default_ingredient_sizes.sort{|a,b| b.use_by_date_diff <=> a.use_by_date_diff}.first.use_by_date_diff
		elsif ing.use_by_date_diff != 0
			return ing.use_by_date_diff
		end

		return 14
	end

end
