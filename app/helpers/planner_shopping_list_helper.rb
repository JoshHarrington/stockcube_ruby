require 'uri'

module PlannerShoppingListHelper
	include ActionView::Helpers::DateHelper
	include PortionStockHelper
	include UtilsHelper
	include ServingHelper
	include CupboardHelper

	def sort_all_planner_portions_by_date(planner_shopping_list = nil)
		## Get all planner portions
		all_planner_portions = planner_shopping_list.planner_shopping_list_portions

		## sort by date to find portion needed soonest
		sorted_planner_portions = all_planner_portions.sort_by{|p|p.date}

		return sorted_planner_portions
	end

	def sum_stock_amounts(amounts_array = [])
		return if amounts_array == [] || amounts_array.length == 0
		return amounts_array.sum
	end

	def shopping_list_class
		return unless current_user && current_user.planner_recipes.select{|pr| pr.date > Date.current - 1.day && pr.date < Date.current + 7.day} && !(params[:controller] == 'planner' && params[:action] == 'list')
		if current_user.planner_recipes.select{|pr| pr.date > Date.current - 1.day && pr.date < Date.current + 7.day}.length > 0 && checked_portions != shopping_list_portions.length
			return 'shopping_list_open'
		end
	end

	def shopping_list_count
		if total_portions > 0
			return checked_portions.to_s + '/' + total_portions.to_s
		else
			return false
		end
	end

	def remove_old_planner_portion(user = nil)
		return if user == nil

		user.planner_recipes.where('date < ?', Date.current).map{|pr| pr.planner_shopping_list_portions.destroy_all}
	end

	def _setup_wrapper_portions(portion = nil, amount = nil, unit_id = nil, current_user = nil, planner_shopping_list_id = nil)
		return if portion == nil || amount == nil || unit_id == nil || user_signed_in? == false || planner_shopping_list_id == nil

		wrapper_portion = PlannerPortionWrapper.find_or_create_by(
			user_id: current_user[:id],
			planner_shopping_list_id: planner_shopping_list_id,
			ingredient_id: portion.ingredient_id
		)
		wrapper_portion.update_attributes(
			amount: amount,
			unit_id: unit_id,
			checked: portion.checked,
			date: portion.date
		)

		PlannerPortionWrapper.where(
			user_id: current_user[:id],
			planner_shopping_list_id: planner_shopping_list_id,
			ingredient_id: portion.ingredient_id
		).where.not(id: wrapper_portion[:id]).destroy_all

		PlannerShoppingListPortion.where(id: portion.id).update_all(
			planner_portion_wrapper_id: wrapper_portion[:id]
		)
		CombiPlannerShoppingListPortion.where(id: portion.id).update_all(
			planner_portion_wrapper_id: wrapper_portion[:id]
		)

	end

	def refresh_all_planner_portions(planner_shopping_list = nil)
		return if planner_shopping_list == nil

		planner_shopping_list.user.remove_old_planner_portions

		## Loop over all relevant (not old) planner recipes
		planner_shopping_list.planner_recipes.select{|pr| pr.date >= Date.current}.each do |pr|

			## Loop over all associated recipe portions
			pr.recipe.portions.each do |rp|

				Rails.logger.debug "refresh_all_planner_portions recipe portions"
				Rails.logger.debug "portion id - #{rp.id} - #{rp.ingredient.name}"

				## Ignore water portions
				next if rp.ingredient.name.downcase == 'water'

				## Create new planner portions using the recipe portion as template
				PlannerShoppingListPortion.find_or_create_by(
					user_id: planner_shopping_list.user_id,
					planner_recipe_id: pr.id,
					ingredient_id: rp.ingredient_id,
					planner_shopping_list_id: planner_shopping_list.id
				).update_attributes(
					unit_id: rp.unit_id,
					amount: rp.amount,
					date: pr.date + get_ingredient_use_by_date_diff(rp.ingredient)
				)

				#### TODO - check if stock already exists?
				####				or can be taken from cupboards
				####				if yes then setup planner portion with checked state

			end
		end
	end

	def delete_old_combi_planner_portions_and_create_new(planner_shopping_list_id = nil)
		return if planner_shopping_list_id == nil

		planner_shopping_list = PlannerShoppingList.find(planner_shopping_list_id)

		Rails.logger.debug "delete_old_combi_planner_portions_and_create_new"
		## Delete all planner combi portions without planner portions
		planner_shopping_list.combi_planner_shopping_list_portions.select{|cp| cp.planner_shopping_list_portions.length == 0}.map{|cp|cp.destroy}

		## Find all planner portions with same ingredient, groups of more than 1
		grouped_planner_portions = planner_shopping_list.planner_shopping_list_portions.group_by{|p| p.ingredient_id}.select{|k,v| v.length > 1}

		if grouped_planner_portions.select{|k,pg| pg.select{|p| p.combi_planner_shopping_list_portion_id == nil}.length > 0}.length > 0

			grouped_planner_portions.each do |ing_id, portion_group|


				combi_amount = combine_grouped_servings(portion_group, true)

				combi_portion = CombiPlannerShoppingListPortion.create(
					user_id: planner_shopping_list.user_id,
					planner_shopping_list_id: planner_shopping_list.id,
					ingredient_id: ing_id,
					amount: combi_amount != nil && combi_amount != false && combi_amount.has_key?(:amount) ? combi_amount[:amount] : nil,
					unit_id: combi_amount != nil && combi_amount != false && combi_amount.has_key?(:unit) ? combi_amount[:unit].id : nil,
					date: portion_group.sort_by{|p| p.planner_recipe.date}.first.date,
					checked: portion_group.count{|p| p.checked == false} > 0 ? false : true
				)

				portion_group.each do |p|
					p.update_attributes(
						combi_planner_shopping_list_portion_id: combi_portion.id
					)
				end

			end
		end

	end

	def update_planner_shopping_list_portions
		return if user_signed_in? == false
		planner_shopping_list = PlannerShoppingList.find_or_create_by(user_id: current_user.id)
		if current_user.planner_recipes && current_user.planner_recipes.length == 0
			current_user.combi_planner_shopping_list_portions.destroy_all
			planner_shopping_list.update_attributes(
				ready: true
			)
			return
		end

		current_user.remove_out_of_date_stock

		refresh_all_planner_portions(planner_shopping_list)

		sorted_planner_portions = sort_all_planner_portions_by_date(planner_shopping_list)

		sorted_planner_portions.each do |portion|
			find_matching_stock_for_portion(portion)
		end

		delete_old_combi_planner_portions_and_create_new(planner_shopping_list.id)

		combine_existing_similar_stock(current_user)


		#### TODO -- figure out how wrapper portions can work alongside developed combi portions

		# all_shopping_list_portions = []
		# planner_shopping_list_portions.reject{|p| p.combi_planner_shopping_list_portion_id != nil}.map{|p| all_shopping_list_portions.push(p)}
		# current_user.combi_planner_shopping_list_portions.select{|cp|cp.date >= Date.current}.map{|cp|all_shopping_list_portions.push(cp)}

		# all_shopping_list_portions.each do |p|

		# 	size_diff = false

		# 	# loop over each default ingredient size to find a size bigger than the portion
		# 	# if no size found, double the ingredient size amounts then rerun the loop
		# 	# keep stepping up sizes until correct size found


		# 	planner_portion_size = find_planner_portion_size(p)

		# 	next if planner_portion_size == false

		# 	amount = planner_portion_size[:converted_size][:amount]
		# 	unit_id = planner_portion_size[:converted_size][:unit_id]

		# 	setup_wrapper_portions(p, amount, unit_id, current_user, planner_shopping_list.id)

		# end

	end


	def combine_divided_stock_after_planner_recipe_delete(planner_recipe = nil)
		return if planner_recipe == nil || planner_recipe.stocks.length < 1
		planner_recipe.stocks.each do |stock|
			stock_partner = stock.cupboard.stocks.where.not(id: stock.id).find_by(ingredient_id: stock.ingredient_id, use_by_date: stock.use_by_date)
			return unless stock_partner.present?
			return if stock_partner.updated_at > Date.current - 10.minutes
			stock_group = [stock_partner, stock]
			if serving_addition(stock_group)
				stock_addition_hash = serving_addition(stock_group)
				stock_amount = stock_addition_hash[:amount]
				stock_unit_id = stock_addition_hash[:unit].id
				stock_partner.update_attributes(
					amount: stock_amount,
					unit_id: stock_unit_id
				)
				stock.delete
			else
				stock.update_attributes(
					planner_recipe_id: nil
				)
			end

		end
	end

	def shopping_list_portions(shopping_list = nil, user = nil)
		if shopping_list == nil && (user_signed_in? || user != nil)
			shopping_list = user != nil ? user.planner_shopping_list : current_user.planner_shopping_list
		elsif shopping_list == nil && user_signed_in? == false
			return []
		elsif user_signed_in? && current_user.planner_shopping_list.present?
			shopping_list = PlannerShoppingList.find_or_create_by(user_id: current_user.id)
		end

		planner_recipe_portions = []
		planner_portions_with_wrap = []
		if shopping_list && shopping_list.planner_recipes && shopping_list.planner_recipes.length > 0
			all_planner_recipe_portions = shopping_list.planner_recipes.select{|pr| pr.date > Date.current - 6.hours && pr.date < Date.current + 7.day}.map{|pr| pr.planner_shopping_list_portions.reject{|p| p.combi_planner_shopping_list_portion_id != nil}.reject{|p| p.ingredient.name.downcase == 'water'}.reject{|p| p.checked == true && p.updated_at < Time.current - 1.day}}.flatten
			planner_recipe_portions = all_planner_recipe_portions.reject{|p|p.planner_portion_wrapper_id != nil}
			planner_portions_with_wrap = all_planner_recipe_portions.reject{|p|p.planner_portion_wrapper_id == nil}
		end

		combi_portions = []
		combi_portions_with_wrap = []
		if shopping_list && shopping_list.combi_planner_shopping_list_portions && shopping_list.combi_planner_shopping_list_portions.length > 0
			# all_combi_portions = shopping_list.combi_planner_shopping_list_portions.select{|c|c.date > Date.current - 6.hours && c.date < Date.current + 7.day}.reject{|cp| cp.checked == true && cp.updated_at < Time.current - 1./day}
			all_combi_portions = shopping_list.combi_planner_shopping_list_portions
			combi_portions = all_combi_portions.reject{|cp|cp.planner_portion_wrapper_id != nil}
			combi_portions_with_wrap = all_combi_portions.reject{|cp|cp.planner_portion_wrapper_id == nil}
		end

		portion_wrappers = []
		if shopping_list && shopping_list.planner_portion_wrappers && shopping_list.planner_portion_wrappers.length > 0
			wrapped_portions = combi_portions_with_wrap + planner_portions_with_wrap
			portion_wrappers = wrapped_portions.map{|p|p.planner_portion_wrapper}
		end


		shopping_list_portions = combi_portions + planner_recipe_portions + portion_wrappers

		session[:sl_checked_portions_count] = shopping_list_portions.count{|p|p.checked == true}
		session[:sl_unchecked_portions_count] = shopping_list_portions.count{|p|p.checked == false}
		session[:sl_total_portions_count] = shopping_list_portions.count

		return shopping_list_portions.sort_by!{|p| p.ingredient.name}

	end

	def processed_shopping_list_portions(sl_portions = nil)
		return [] if sl_portions == nil

		return sl_portions.map{|p| {
			encodedId: planner_portion_id_hash.encode(p.id),
			checked: p.checked,
			description: serving_description(p),
			type: p.class == CombiPlannerShoppingListPortion ? 'combi_portion' : 'individual_portion',
			freshForTime: (p.date - Date.today).to_i
		}}
	end

	def return_portions_for_planner_recipe(planner_recipe_id = nil)
		return [] if planner_recipe_id == nil

		planner_recipe = PlannerRecipe.find(planner_recipe_id)

		planner_stocks = planner_recipe.planner_shopping_list_portions
											.map{|p| p.stock}.compact
											.select{|s|s.hidden == false && s.always_available == false}
											.sort_by{|s| s.use_by_date}
		needed_stocks = planner_recipe.recipe.portions.where.not(ingredient_id: planner_stocks.map(&:ingredient_id).uniq).select{|p| p.ingredient.name.downcase != 'water'}

		planner_stocks_array = planner_stocks.map{|s| {
			percentInCupboards: percentage_of_portion_in_stock(s),
			title: serving_description(s.planner_shopping_list_portion),
			fresh: s.use_by_date >= Time.zone.now,
			freshForTime: distance_of_time_in_words(Time.zone.now, s.use_by_date)
		}}

		needed_stocks_array = needed_stocks.map{|s| {
			percentInCupboards: 0,
			title: serving_description(s),
			freshForTime: nil,
			fresh: nil
		}}

		combined_stocks_array = planner_stocks_array + needed_stocks_array
		return combined_stocks_array
	end

	def processed_recipe(recipe = nil, planner_recipe_id = nil, return_portions = false)
		return nil if recipe == nil

		recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		planner_recipe_id_hash = Hashids.new(ENV['PLANNER_RECIPE_ID_SALT'])

		return {
			encodedId: recipe_id_hash.encode(recipe.id),
			title: recipe.title,
			percentInCupboards: percent_in_cupboards(recipe).to_s,
			path: recipe_path(recipe),
			stockInfoNote: "#{num_stock_ingredients(recipe)} of #{recipe.portions.length} ingredients in stock",
			plannerRecipeId: planner_recipe_id,
			portions: return_portions && return_portions_for_planner_recipe(planner_recipe_id_hash.decode(planner_recipe_id).first)
		}
	end

	def processed_recipe_list(recipes = nil)
		return if recipes == nil

		recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])

		return recipes.map{|r| processed_recipe(r)}

	end

	def processed_recipe_list_for_user(user = nil)
		return if user == nil

		recipes = user.user_recipe_stock_matches.order(ingredient_stock_match_decimal: :desc).reject{|u_r| current_planner_recipe_ids.include?(u_r.recipe_id) }.select{|u_r| u_r.recipe && u_r.recipe.portions.length != 0 && (u_r.recipe[:public] || u_r.recipe[:user_id] == current_user[:id])}[0..11].map{|u_r| u_r.recipe}

		return processed_recipe_list(recipes)
	end

	# def processed_planner_list(user = nil)
	# 	return if user == nil

	# 	date_range = (-1..31)
	# 	planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])

	# 	return date_range.map{|d|
	# 		date = Date.current + d.days
	# 		date_num = date.to_formatted_s(:number)
	# 		date_id = planner_recipe_date_hash.encode(date_num)
	# 		calendar_note = nil
	# 		if d == -1
	# 			calendar_note = "Yesterday " + date.to_s(:short)
	# 		elsif d == 0
	# 			calendar_note = "Today " + date.to_s(:short)
	# 		elsif d == 1
	# 			calendar_note = "Tomorrow " + date.to_s(:short)
	# 		else
	# 			calendar_note = date.to_s(:short)
	# 		end

	# 		planner_recipes = user.planner_recipes.where(date: date)

	# 		{
	# 			dateId: date_id,
	# 			calendarNote: calendar_note
	# 		}
	# 	}

	# end

	# def processed_planner_recipes_by_date(user = nil)
	# 	return if user == nil

	# 	planner_recipe_id_hash = Hashids.new(ENV['PLANNER_RECIPE_ID_SALT'])
	# 	planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])

	# 	planner_recipes_by_date = user.planner_recipes.select{|pr|pr.date > Date.current - 2.day}.group_by{|pr| [planner_recipe_date_hash.encode(pr.date.to_formatted_s(:number)), pr.date.to_formatted_s(:iso8601)] }
	# 	processed_planner_recipes_by_date_hash = planner_recipes_by_date.map{|(encoded_date_id, date_string), prs| {
	# 		encodedDateId: encoded_date_id,
	# 		date: date_string,
	# 		plannerRecipes: prs.map{|pr|processed_recipe(pr.recipe, planner_recipe_id_hash.encode(pr.id))}
	# 	}}

	# 	return processed_planner_recipes_by_date_hash
	# end

	def processed_planner_recipes_with_date(user = nil, return_portions = false)

		planner_recipe_id_hash = Hashids.new(ENV['PLANNER_RECIPE_ID_SALT'])
		planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])

		user_planner_recipes = user.planner_recipes.sort_by{|pr| pr.date }
		processed_planner_recipes_with_date_hash = user_planner_recipes.map{|pr| {
			encodedDateId: planner_recipe_date_hash.encode(pr.date.to_formatted_s(:number)),
			date: pr.date.to_formatted_s(:iso8601),
			encodedId: planner_recipe_id_hash.encode(pr.id),
			plannerRecipe: processed_recipe(pr.recipe, planner_recipe_id_hash.encode(pr.id), return_portions),
			active: pr.date >= Date.current && pr.date <= Date.current + 6.days,
			recipeHref: recipe_path(pr.recipe),
			humanDate: pr.date.to_s(:short)
		}}

		return processed_planner_recipes_with_date_hash
	end

	def email_sharing_mailto_list(shopping_list_portions = nil, shopping_list_gen_id = nil)
		return if shopping_list_portions == nil
		return "" if shopping_list_portions.length == 0

		intro = URI.escape('These are the ingredients needed for upcoming meals:') + '%0D%0A%0D%0A'

		unchecked_portions = shopping_list_portions.select{|p| p.checked == false}
		return "" if unchecked_portions.length == 0 || unchecked_portions == nil

		escaped_portion_list = unchecked_portions.select{|p| p != nil && stock_needed_serving_description(p) != nil }.map{|p| '- ' + URI.escape(stock_needed_serving_description(p)).to_s}.join('%0D%0A')
		escaped_portion_list_with_pluses = escaped_portion_list != nil ? escaped_portion_list.gsub(/\+/, '%2B') : ""

		link_to_public_shopping_list = ''
		if shopping_list_gen_id != nil
			link_to_public_shopping_list = '%0D%0A%0D%0A%0D%0A--%0D%0A' + URI.escape('Check off items with Stockcubes to add them to your digital cupboard!') + '%0D%0A' + URI.escape(shopping_list_share_url(gen_id: shopping_list_gen_id)).to_s
		elsif user_signed_in?
			link_to_public_shopping_list = '%0D%0A%0D%0A%0D%0A--%0D%0A' + URI.escape('Check off items with Stockcubes to add them to your digital cupboard!') + '%0D%0A' + URI.escape(shopping_list_share_url(gen_id: current_user.planner_shopping_list.gen_id)).to_s
		end

		link_to_stockcubes = '%0D%0A%0D%0A--%0D%0A' + URI.escape('This shopping list was created with Stockcubes') + '%0D%0A' + URI.escape('Learn more about Stockcubes at: ' + root_url)
		if shopping_list_gen_id != nil
			link_to_stockcubes = '%0D%0A%0D%0A' + URI.escape('Learn more about Stockcubes at: ' + root_url)
		end


		return "mailto:?subject=Shopping%20List%20from%20Stockcubes&body=#{intro}#{ escaped_portion_list_with_pluses }#{link_to_public_shopping_list}#{link_to_stockcubes}"
	end

	def unchecked_portions
		add_portion_counts_to_session
		return session[:sl_unchecked_portions_count]
	end

	def checked_portions()
		add_portion_counts_to_session
		return session[:sl_checked_portions_count]
	end

	def total_portions()
		add_portion_counts_to_session
		return session[:sl_total_portions_count]
	end

	def user_recipe_stock_match_check(recipe_id = nil)
		return nil if user_signed_in? == false || recipe_id == nil
		return UserRecipeStockMatch.find_by(user_id: current_user.id, recipe_id: recipe_id)
	end

	def retrieve_recipe_stock_match_detail(recipe = nil, key = nil)
		return 0 if recipe == nil || key == nil || user_signed_in? == false

		user_recipe_stock_match = user_recipe_stock_match_check(recipe.id)
		return 0 if user_recipe_stock_match == nil

		match_detail = user_recipe_stock_match[key]
		return 0 if match_detail == nil
		return match_detail
	end

	def percent_in_cupboards(recipe = nil)
		ingredient_stock_match_decimal = retrieve_recipe_stock_match_detail(recipe, :ingredient_stock_match_decimal)
		return ingredient_stock_match_decimal != nil ? (ingredient_stock_match_decimal.to_f * 100).round : 0
	end

	def num_stock_ingredients(recipe = nil)
		return retrieve_recipe_stock_match_detail(recipe, :num_stock_ingredients)
	end

	def num_needed_ingredients(recipe = nil)
		return retrieve_recipe_stock_match_detail(recipe, :num_needed_ingredients)
	end

	def add_portion_counts_to_session
		unless session.has_key?(:sl_checked_portions_count)
			shopping_list_portions_var = shopping_list_portions
			session[:sl_checked_portions_count] = shopping_list_portions_var.count{|p|p.checked == true}
			session[:sl_unchecked_portions_count] = shopping_list_portions_var.count{|p|p.checked == false}
			session[:sl_total_portions_count] = shopping_list_portions_var.count
		end
	end

	def planner_portion_id_hash
		return Hashids.new(ENV['PLANNER_PORTIONS_SALT'])
	end

	def current_planner_recipe_ids
		return [] if user_signed_in? == false
		return current_user.planner_recipes.where(date: Date.current..Date.current+7.days).map(&:recipe_id)
	end

	def update_current_planner_recipe_ids
		if user_signed_in?
			session[:current_planner_recipe_ids] = current_user.planner_recipes.where(date: Date.current..Date.current+7.days).map(&:recipe_id)
		end
	end

	def update_portion_details(params)

		if params.has_key?(:gen_id) && PlannerShoppingList.find_by(gen_id: params[:gen_id])
			shopping_list = PlannerShoppingList.find_by(gen_id: params[:gen_id])
		elsif current_user
			shopping_list = current_user.planner_shopping_list
		else
			return
		end

		return unless params.has_key?(:shopping_list_portion_id) && params.has_key?(:portion_type)
		shopping_list.update_attributes(
			ready: false
		)

		planner_portion = nil

		if params[:portion_type] == 'combi_portion'
			planner_portion = shopping_list.combi_planner_shopping_list_portions.find(planner_portion_id_hash.decode(params[:shopping_list_portion_id])).first
		elsif params[:portion_type] == 'individual_portion'
			planner_portion = shopping_list.planner_shopping_list_portions.find(planner_portion_id_hash.decode(params[:shopping_list_portion_id])).first
		elsif params[:portion_type] == 'wrapper_portion'
			planner_portion = shopping_list.planner_portion_wrappers.find(planner_portion_id_hash.decode(params[:shopping_list_portion_id])).first.planner_shopping_list_portion
		end


		if planner_portion != nil
			planner_portion.update_attributes(date: params[:date])
			setup_wrapper_portions(planner_portion, params[:amount], params[:unit_id], current_user, shopping_list.id)
		end


		shopping_list.update_attributes(
			ready: true
		)

	end
end
