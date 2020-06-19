module PortionStockHelper
	include UtilsHelper
	include ApplicationHelper
	include CupboardHelper
	include IngredientsHelper

	def combine_stock_group(stock_group = nil, user = nil)
		return if stock_group == nil || user == nil

		cupboard_id = user_cupboards(user).first.id

		similar_stocks_group_for_metric = stock_group.uniq
			.select{|s|
				s.unit.unit_type != nil && s.planner_shopping_list_portion_id == nil && s.hidden == false
			}.group_by{|s| [s.ingredient_id, s.unit.unit_type]}

		matching_metric_stock_hash = similar_stocks_group_for_metric.select{|(i, ut),v| v.length > 1 }

		matching_metric_stock_hash.each do |(ingredient_id, unit_type), stocks|
			stock_amount_array = stocks.map{ |s|
				standardise_amount_with_metric_ratio(s.amount, s.unit.metric_ratio)
			}
			first_unit = stocks.first.unit
			stock_amount = sum_stock_amounts(stock_amount_array) / first_unit.metric_ratio

			use_by_date = stocks.sort_by{|s|s.use_by_date}.first.use_by_date

			new_stock_create(user, stock_amount, first_unit.id, use_by_date, ingredient_id, cupboard_id)

			stocks.map{|s| s.destroy}
		end

		similar_stocks_group_for_non_metric = stock_group
			.select{|s|
				s.unit.unit_type == nil && s.planner_shopping_list_portion_id == nil && s.hidden == false
			}.group_by{|s| [s.ingredient_id, s.unit_id]}
		matching_non_metric_stock_hash = similar_stocks_group_for_non_metric.select{|(i, uid),v| v.length > 1}

		matching_non_metric_stock_hash.each do |(ingredient_id, unit_id), stocks|
			summed_stock_amount = stocks.map{|s|s.amount}.sum
			use_by_date = stocks.sort_by{|s|s.use_by_date}.first.use_by_date

			new_stock_create(user, summed_stock_amount, unit_id, use_by_date, ingredient_id, cupboard_id)

			stocks.map{|s| s.destroy}
		end

  end


	def combine_existing_similar_stock(user = nil)
		return if user == nil

		user_stock_multiples = user_stock_multiples(user)
		combine_stock_group(user_stock_multiples, user)
  end


	def percentage_of_portion_in_stock(stock = nil)
		return 0 if stock == nil

		portion = stock.planner_shopping_list_portion
		return 0 if portion == nil

		return 0 if stock.ingredient_id != portion.ingredient_id
		return 0 if stock.unit.unit_type != portion.unit.unit_type

		if stock.unit.unit_type != nil

			metric_stock_amount = standardise_amount_with_metric_ratio(stock.amount, stock.unit.metric_ratio)
			metric_portion_amount = standardise_amount_with_metric_ratio(portion.amount, portion.unit.metric_ratio)

			portion_in_stock_percentage = (metric_stock_amount / metric_portion_amount.to_f) * 100

			if portion_in_stock_percentage > 100
				return 100
			else
				return portion_in_stock_percentage.round()
			end
		else
			return 0 if stock.unit_id != portion.unit_id

			portion_in_stock_percentage = (stock.amount / portion.amount.to_f) * 100

			if portion_in_stock_percentage > 100
				return 100
			else
				return portion_in_stock_percentage.round()
			end
		end

  end


	def new_stock_create(user = nil, amount = nil, unit_id = nil, use_by_date = nil, ingredient_id = nil, cupboard_id = nil, portion = nil)
		return if user == nil || amount == nil || unit_id == nil || use_by_date == nil || ingredient_id == nil || cupboard_id == nil

		return if !!portion && portion.ingredient.name.downcase == "water"
		new_stock = Stock.find_or_create_by(
			amount: amount,
			unit_id: unit_id,
			cupboard_id: cupboard_id,
			hidden: false,
			always_available: false,
			use_by_date: use_by_date,
			ingredient_id: ingredient_id,
			planner_shopping_list_portion_id: nil,
			planner_recipe_id: nil
		)
		if !!portion
			new_stock.update_attributes(
				planner_shopping_list_portion_id: portion.id,
				planner_recipe_id: portion.planner_recipe_id != nil ? portion.planner_recipe_id : nil
			)
		end

		StockUser.find_or_create_by(
			stock_id: new_stock.id,
			user_id: user.id
		)
  end


	def remove_stock_after_portion_unchecked(planner_portion = nil, portion_type = nil)
		Rails.logger.debug "remove_stock_after_portion_unchecked"
		return if planner_portion == nil || portion_type == nil

		if portion_type == "combi_portion"
			planner_portion.planner_shopping_list_portions.each do |portion|
				if portion.stock != nil
					portion.stock.destroy
				end
			end
		elsif portion_type == "individual_portion"
			if planner_portion.stock != nil
				planner_portion.stock.destroy
			end
		end
	end

	def add_stock_after_portion_checked(planner_portion = nil, portion_type = nil)
		Rails.logger.debug "add_stock_after_portion_checked"
		return if planner_portion == nil || portion_type == nil

		user = planner_portion.user

		if portion_type == "combi_portion"
			# why destroy associated stock?
			# conflict with `before_destroy :uncheck_planner_portions` in stock.rb

			# planner_portion.planner_shopping_list_portions.map{|p| p.stock.destroy if p.stock }
			planner_portion.planner_shopping_list_portions.each do |portion|
				check_if_planner_stock_exists_before_creating(portion)
			end
		elsif portion_type == "individual_portion"
			check_if_planner_stock_exists_before_creating(planner_portion)
			if planner_portion.combi_planner_shopping_list_portion_id != nil

				combi_portion = planner_portion.combi_planner_shopping_list_portion
				if combi_portion.planner_shopping_list_portions.count{|p|p.checked == false} == 0
					combi_portion.update_attributes(checked: true)
				end
			end
		end

	end

	def check_if_planner_stock_exists_before_creating(portion = nil)
		return if portion == nil
		user = portion.user

		if portion.stock != nil
			portion.stock.delete
			return
		else
			new_stock_create(user, portion.amount, portion.unit_id, (portion.planner_recipe.date + 2.weeks), portion.ingredient_id, first_cupboard(user).id, portion)
		end

	end


	def find_matching_stock_for_portion(portion = nil)
		return if portion == nil

		user = portion.user
		user_cupboards = user_cupboards(user)
		user_stock = user_stock(user)

		available_stock = user_stock.select{|s|s.hidden == false && s.always_available == false && s.use_by_date > Date.current - stock_date_limit.day}
			.select{|s|	s.ingredient_id == portion.ingredient_id}

		return if available_stock.length == 0

		### check if portion is metric
		if portion.unit.unit_type != nil


			subsection_of_available_metric_stock = available_stock.select{|s|s.unit.unit_type != nil}

			if subsection_of_available_metric_stock.length > 1

				combine_stock_group(subsection_of_available_metric_stock, user)

				## if not passing the stock back in at this point then need to run function again
				## this way there should only be max 1 stock to compare against
				find_matching_stock_for_portion(portion)
			elsif subsection_of_available_metric_stock.length == 1

				comparable_stock = subsection_of_available_metric_stock.first

				metric_stock_amount = standardise_amount_with_metric_ratio(comparable_stock.amount, comparable_stock.unit.metric_ratio)
				metric_portion_amount = standardise_amount_with_metric_ratio(portion.amount, portion.unit.metric_ratio)

				metric_unit = Unit.find_by(metric_ratio: 1, unit_type: portion.unit.unit_type)

				if metric_stock_amount >= metric_portion_amount

					## create new stock from portion
					new_stock_create(user, portion.amount, portion.unit_id, comparable_stock.use_by_date, portion.ingredient_id, user_cupboards.first.id, portion)

					if metric_stock_amount == metric_portion_amount
						comparable_stock.destroy
					else
						## reduce comparable stock amount by proportional amount
						comparable_stock.update_attributes(
							planner_shopping_list_portion_id: portion.id,
							unit_id: metric_unit.id,
							amount: metric_stock_amount - metric_portion_amount
						)
					end

					portion.update_attributes(
						checked: true
					)

				else

					stock_amount = metric_stock_amount / portion.unit.metric_ratio

					comparable_stock.update_attributes(
						planner_shopping_list_portion_id: portion.id,
						amount: stock_amount,
						unit_id: portion.unit_id,
						planner_recipe_id: portion.planner_recipe_id
					)

					### could add extra column to planner portion table to record amount in stock
					### right now just need to do check on what stock associated to planner portion
					### and report on what percentage of that planner portion amount is in stock

				end
			end



		## otherwise portion not metric
		else

			subsection_of_available_stock_non_metric = available_stock.select{|s|s.unit.unit_type == nil && s.unit_id == portion.unit_id}

			if subsection_of_available_stock_non_metric.length > 1
				combine_stock_group(subsection_of_available_stock_non_metric, user)

				## if not passing the stock back in at this point then need to run function again
				## this way there should only be max 1 stock to compare against
				find_matching_stock_for_portion(portion)
			elsif subsection_of_available_stock_non_metric.length == 1

				comparable_stock = subsection_of_available_stock_non_metric.first

				stock_amount = comparable_stock.amount
				portion_amount = portion.amount

				if stock_amount >= portion_amount
					## create new stock from portion
					new_stock_create(user, portion.amount, portion.unit_id, comparable_stock.use_by_date, portion.ingredient_id, user_cupboards.first.id, portion)

					if stock_amount == portion_amount
						comparable_stock.destroy
					else
						## reduce comparable stock amount by proportional amount
						comparable_stock.update_attributes(
							amount: stock_amount - portion_amount
						)
					end

					portion.update_attributes(
						checked: true
					)

				else

					comparable_stock.update_attributes(
						planner_shopping_list_portion_id: portion.id,
						planner_recipe_id: portion.planner_recipe_id
					)

					### could add extra column to planner portion table to record amount in stock
					### right now just need to do check on what stock associated to planner portion
					### and report on what percentage of that planner portion amount is in stock

				end
			end
		end
	end

	def combine_grouped_servings(serving_array = [], find_stock_needed_bool = true)
		return if serving_array == [] || serving_array.length == 0

		portion_group_with_stock_diff = []
		serving_array.each do |planner_portion|
			return nil if planner_portion.class != PlannerShoppingListPortion
			converted_planner_portion = serving_converter(planner_portion)

			if find_stock_needed_bool && planner_portion.stock != nil
				converted_planner_portion_stock = serving_converter(planner_portion.stock)

				portion_stock_diff = serving_difference([converted_planner_portion, converted_planner_portion_stock])

				if portion_stock_diff != false
					portion_group_with_stock_diff.push(portion_stock_diff)
				else
					### planner portion - stock didn't work, so add planner portion anyway
					portion_group_with_stock_diff.push(serving_converter(planner_portion))
				end
			else

				converted_serving = serving_converter(planner_portion)

				if converted_serving != false
					portion_group_with_stock_diff.push(converted_serving)
				end
			end
		end


		combi_portions_added = serving_addition(portion_group_with_stock_diff)


		combi_amount = combi_portions_added && combi_portions_added[:unit].unit_type != nil ? convert_to_different_unit(combi_portions_added, serving_array.first.unit) : combi_portions_added
		return combi_amount
	end

	def list_grouped_stock(serving_list = [], find_stock_needed_bool = true)
		return if serving_list == [] || serving_list.length == 0
		if serving_list.group_by{|s|s.ingredient_id}.length > 1
			Rails.logger.debug "multiple ingredient types passed in"
			raise "Multiple ingredients passed in, should only be one type"

			return nil
		end

		ingredient_list_group = []

		serving_list.select{|s|s.unit.unit_type != nil}.group_by{|s|s.unit.unit_type}.each do |u_type, s|
			ingredient_list_group.push(s)
		end

		serving_list.select{|s|s.unit.unit_type == nil}.group_by{|s|s.unit_id}.each do |u_id, s|
			ingredient_list_group.push(s)
		end

		list_grouped_stock = []
		ingredient_list_group.each do |portion_group|
			combined_similar_portions_minus_stock = combine_grouped_servings(portion_group, find_stock_needed_bool)

			combined_similar_portions_minus_stock_amount = combined_similar_portions_minus_stock[:amount]
			combined_similar_portions_minus_stock[:amount] = ("%.3g" % combined_similar_portions_minus_stock_amount).to_f

			if combined_similar_portions_minus_stock != nil
				list_grouped_stock.push(combined_similar_portions_minus_stock)
			end
		end

		return list_grouped_stock

	end

end