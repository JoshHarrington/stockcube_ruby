require 'uri'

module PlannerShoppingListHelper
	include PortionStockHelper
	include UtilsHelper
	include ServingHelper

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

		## Loop over all planner recipes
		planner_shopping_list.planner_recipes.each do |pr|

			## Ignore old planner recipes
			if pr.date < Date.current
				pr.destroy
			else

				## Loop over all associated recipe portions
				pr.recipe.portions.each do |rp|

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
	end

	def delete_all_combi_planner_portions_and_create_new(planner_shopping_list_id = nil)
		return if planner_shopping_list_id == nil

		planner_shopping_list = PlannerShoppingList.find(planner_shopping_list_id)

		Rails.logger.debug "delete_all_combi_planner_portions_and_create_new"
		## Delete all planner combi portions
		planner_shopping_list.combi_planner_shopping_list_portions.destroy_all

		Rails.logger.debug planner_shopping_list.planner_shopping_list_portions.group_by{|p| p.ingredient_id}.select{|k,v| v.length > 1}

		## Find all planner portions with same ingredient
		planner_shopping_list.planner_shopping_list_portions.group_by{|p| p.ingredient_id}.select{|k,v| v.length > 1}.each do |ing_id, portion_group|


			combi_amount = combine_grouped_servings(portion_group, true)

			Rails.logger.debug "combi_amount"
			Rails.logger.debug combi_amount

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


		refresh_all_planner_portions(planner_shopping_list)

		sorted_planner_portions = sort_all_planner_portions_by_date(planner_shopping_list)

		Rails.logger.debug "sorted_planner_portions"
		Rails.logger.debug sorted_planner_portions

		sorted_planner_portions.each do |portion|
			find_matching_stock_for_portion(portion)
		end

		delete_all_combi_planner_portions_and_create_new(planner_shopping_list.id)

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

	def shopping_list_portions(shopping_list = nil)
		if shopping_list == nil && current_user && current_user.planner_shopping_list.present?
			shopping_list = current_user.planner_shopping_list
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

		Rails.logger.debug "combi_portions"
		Rails.logger.debug combi_portions

		return shopping_list_portions.sort_by!{|p| p.ingredient.name}

	end

	def email_sharing_mailto_list(shopping_list_portions = nil, shopping_list_gen_id = nil)
		return if shopping_list_portions == nil
		return "" if shopping_list_portions.length == 0

		intro = URI.escape('These are the ingredients needed for upcoming meals:') + '%0D%0A%0D%0A'

		unchecked_portions = shopping_list_portions.select{|p| p.checked == false}
		return "" if unchecked_portions.length == 0

		escaped_portion_list = unchecked_portions.map{|p|'- ' + URI.escape(stock_needed_serving_description(p)).to_s}.join('%0D%0A')
		escaped_portion_list_with_pluses = escaped_portion_list.gsub(/\+/, '%2B')

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

	def checked_portions
		add_portion_counts_to_session
		return session[:sl_checked_portions_count]
	end

	def total_portions
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
