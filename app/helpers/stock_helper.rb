module StockHelper
	include ApplicationHelper

	include PlannerShoppingListHelper
	include CupboardHelper

	include PortionStockHelper

	# if updating one or more ingredients (stock addition) - ingredient_id should be defined
	# if no ingredient_id defined then use all of current users stock to search for matching recipes

	def update_recipe_stock_matches_core(ingredient_ids = nil, user_id = nil, recipe_ids = nil)

		if user_id != nil
			user_id = user_id
		elsif current_user
			user_id = current_user[:id]
		else
			return
		end

		active_cupboard_ids = CupboardUser.where(user_id: user_id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard == nil && (cu.cupboard.setup == true || cu.cupboard.hidden == true) }.compact
		cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: active_cupboard_ids, hidden: false, planner_recipe_id: nil).where("use_by_date >= :date", date: Date.current - 2.days).map{ |s| s.ingredient_id }.uniq.compact

		filtered_ingredient_ids = [].push(ingredient_ids).uniq.flatten.compact
		filtered_recipe_ids = [].push(recipe_ids).uniq.flatten.compact

		search_recipes = []
		collected_recipes = []
		if filtered_recipe_ids.length > 0
			collected_recipes = Recipe.find(filtered_recipe_ids)
		elsif filtered_ingredient_ids.length > 0
			ingredient_names = Ingredient.find(filtered_ingredient_ids).map(&:name)
			search_recipes = Recipe.where(live: true, public: true).or(Recipe.where(user_id: user_id)).search(ingredient_names, operator: "or", fields: ["ingredient_names^100"]).results.uniq
		end
		if filtered_recipe_ids.length == 0 && filtered_ingredient_ids.length == 0
			collected_recipes = Recipe.where(live: true, public: true).or(Recipe.where(user_id: user_id)).uniq.reject{|r| !r.portions || r.portions.length == 0}
		end

		all_recipes = collected_recipes + search_recipes
		all_recipes.each do |recipe|
			recipe_stock_update(recipe, cupboard_stock_in_date_ingredient_ids, user_id)
		end
	end

	def	update_recipe_stock_matches(ingredient_ids = nil, user_id = nil, recipe_ids = nil)
		if user_id != nil
			user_id = user_id
			user = User.find(user_id)
		elsif current_user
			user_id = current_user[:id]
			user = current_user
		else
			return
		end
		return unless (user.user_recipe_stock_matches.present? && user.user_recipe_stock_matches.order("updated_at desc").first.updated_at < 20.minutes.ago) || !user.user_recipe_stock_matches.present?
		update_recipe_stock_matches_core(ingredient_ids, user_id, recipe_ids)

		flash[:info] = %Q[We've updated your <a href="/recipes">recipe list</a> based on your stock so you can see the quickest recipes to make]

	end

	def _create_stock_from_portion(portion = nil, cupboard_id = nil, shopping_list_user = nil, amount = nil)
		return if portion == nil || cupboard_id == nil || shopping_list_user == nil

		if amount != nil && amount != 0
			stock_amount = amount
		else
			stock_amount = portion.amount
		end

		puts "create_stock_from_portion"
		puts portion.id

		recipe_stock = Stock.find_by(
			ingredient_id: portion.ingredient_id,
			unit_id: portion.unit_id,
			planner_shopping_list_portion_id: portion.id
		)
		if recipe_stock != nil && stock_amount > 0
			recipe_stock.update_attributes(
				amount: stock_amount,
				use_by_date: portion.date,
				cupboard_id: cupboard_id,
				always_available: false
			)
			if portion.has_attribute?(:planner_recipe_id)
				recipe_stock.update_attributes(
					planner_recipe_id: portion.planner_recipe_id
				)
			end
		elsif stock_amount > 0
			recipe_stock = Stock.create(
				ingredient_id: portion.ingredient_id,
				amount: stock_amount,
				unit_id: portion.unit_id,
				use_by_date: portion.date,
				cupboard_id: cupboard_id,
				always_available: false,
				planner_shopping_list_portion_id: portion.id
			)
			if portion.has_attribute?(:planner_recipe_id)
				recipe_stock.update_attributes(
					planner_recipe_id: portion.planner_recipe_id
				)
			end
			shopping_list_user.stocks << recipe_stock
		end

		return recipe_stock
	end

	def recipe_stock_update(recipe, cupboard_stock_in_date_ingredient_ids, user_id)
		recipe_ingredient_ids = recipe.portions.map(&:ingredient_id)
		num_ingredients_total = recipe_ingredient_ids.length.to_i
		recipe_stock_ingredient_matches = recipe_ingredient_ids & cupboard_stock_in_date_ingredient_ids
		num_stock_ingredients = recipe_stock_ingredient_matches.length.to_i
		ingredient_stock_match_decimal = num_stock_ingredients.to_f / num_ingredients_total.to_f
		num_needed_ingredients = num_ingredients_total - num_stock_ingredients

		UserRecipeStockMatch.find_or_create_by(
			recipe_id: recipe[:id],
			user_id: user_id
		).update_attributes(
			ingredient_stock_match_decimal: ingredient_stock_match_decimal,
			num_ingredients_total: num_ingredients_total,
			num_stock_ingredients: num_stock_ingredients,
			num_needed_ingredients: num_needed_ingredients
		)
	end

	def _convert_portions_to_stock(portions, processing_type, user_id = nil)
		portions_array = [].push(portions).flatten
		if current_user
			shopping_list_user = current_user
		elsif user_id != nil
			shopping_list_user = User.find(user_id)
		else
			return
		end

		cupboard_id = shopping_list_user.cupboard_users.where(accepted: true).select{|cu| cu.cupboard.setup == false && cu.cupboard.hidden == false }.map{|cu| cu.cupboard }.sort_by{|c| c.updated_at}.first.id
		portions_array.each do |portion|
			next if portion.class.name != "PlannerShoppingListPortion"

			if processing_type && (processing_type == 'remove_portion' || processing_type == 'add_portion')
				check_state = processing_type == 'remove_portion' ? false : true
				if portion.planner_portion_wrapper == nil

					puts "convert_portions_to_stock portion.planner_portion_wrapper == nil  #{portion.ingredient.name}"

					recipe_stock = create_stock_from_portion(portion, cupboard_id, shopping_list_user)
					stock_hidden = processing_type == 'add_portion' ? false : true
					recipe_stock.update_attributes(hidden: stock_hidden)
				else

					portion.planner_portion_wrapper.update_attributes(checked: check_state)


					if processing_type == 'remove_portion'

						puts "convert_portions_to_stock  processing_type == 'remove_portion' #{portion.ingredient.name}"

						wrapper_stock = Stock.where(
							ingredient_id: portion.ingredient_id,
							unit_id: portion.unit_id,
							planner_portion_wrapper_id: portion.planner_portion_wrapper_id
						)
						wrapper_stock.destroy_all

						other_wrapped_stock = Stock.where(
							ingredient_id: portion.ingredient_id,
							unit_id: portion.unit_id,
							planner_shopping_list_portion_id: portion.id
						)
						other_wrapped_stock.destroy_all

					elsif processing_type == 'add_portion'

						puts "convert_portions_to_stock  processing_type == 'add_portion' #{portion.ingredient.name}"

						## find diff between portion size and wrapper size
						## create new stock with this leftover size
						## add planner_portion_wrapper_id to stock
						wrapper_stock_diff = serving_difference([portion.planner_portion_wrapper, portion])
						if wrapper_stock_diff != false
							create_stock_from_portion(portion, cupboard_id, shopping_list_user)

							wrapper_stock = Stock.find_by(
								ingredient_id: portion.ingredient_id,
								unit_id: wrapper_stock_diff[:unit].id,
								planner_portion_wrapper_id: portion.planner_portion_wrapper_id
							)
							if wrapper_stock != nil && wrapper_stock_diff[:amount] > 0
								wrapper_stock.update_attributes(
									amount: wrapper_stock_diff[:amount],
									use_by_date: portion.date,
									cupboard_id: cupboard_id,
									always_available: false
								)
							elsif wrapper_stock_diff[:amount] > 0
								wrapper_stock = Stock.create(
									ingredient_id: portion.ingredient_id,
									amount: wrapper_stock_diff[:amount],
									unit_id: wrapper_stock_diff[:unit].id,
									use_by_date: portion.date,
									cupboard_id: cupboard_id,
									always_available: false,
									planner_portion_wrapper_id: portion.planner_portion_wrapper_id
								)
								shopping_list_user.stocks << wrapper_stock
							end
							if wrapper_stock.present?
								stock_hidden = processing_type == 'add_portion' ? false : true
								wrapper_stock.update_attributes(hidden: stock_hidden)
							end
						elsif portion.unit_id == portion.planner_portion_wrapper.unit_id && portion.amount < portion.planner_portion_wrapper.amount
							create_stock_from_portion(portion, cupboard_id, shopping_list_user, nil)

							planner_wrapper_amount = portion.planner_portion_wrapper.amount - portion.amount
							create_stock_from_portion(portion.planner_portion_wrapper, cupboard_id, shopping_list_user, planner_wrapper_amount)
						else
							create_stock_from_portion(portion.planner_portion_wrapper, cupboard_id, shopping_list_user)
						end
					end
				end
				if portion.combi_planner_shopping_list_portion != nil && portion.combi_planner_shopping_list_portion.checked != check_type
					portion.combi_planner_shopping_list_portion.update_attributes(checked: check_state)
				elsif portion.class.name == "PlannerShoppingListPortion" && portion.checked != check_state
					portion.update_attributes(checked: check_state)
				end
			end


		end

	end

	def user_unique_ingredients(user_id = nil)
		user = nil
		if user_id == nil && current_user != nil
			user = current_user
		elsif user_id != nil
			user = User.find(user_id)
		end

		if user != nil
			stock = user_stock(user)
			return stock.map{|s|s.ingredient}.uniq
		end
	end

	def initial_typical_ingredients
		return [{
			name: 'milk',
			use_by_date_diff: 7
		},{
			name: 'egg',
			use_by_date_diff: 28
		},{
			name: 'bread',
			use_by_date_diff: 7
		},{
			name: 'tomato',
			use_by_date_diff: 7
		},{
			name: 'onion',
			use_by_date_diff: 42
		},{
			name: 'cheddar cheese',
			use_by_date_diff: 42
		},{
			name: 'carrot',
			use_by_date_diff: 28
		},{
			name: 'chicken breast',
			use_by_date_diff: 3
		},{
			name: 'rice',
			use_by_date_diff: 730
		},{
			name: 'pasta',
			use_by_date_diff: 365
		},{
			name: 'olive oil',
			use_by_date_diff: 730
		},{
			name: 'greek yogurt',
			use_by_date_diff: 14
		},{
			name: 'potato',
			use_by_date_diff: 21
		},{
			name: 'flour',
			use_by_date_diff: 182
		},{
			name: 'frozen peas',
			use_by_date_diff: 273
		}]
	end

	def ordered_typical_ingredients(user_id = nil)
		user = nil
		if user_id == nil && current_user != nil
			user = current_user
		elsif user_id != nil
			user = User.find(user_id)
		end


		if user != nil
			uniq_ingredients = user_unique_ingredients(user.id)
			initial_typical_ingredients

			ordered_typical_ingredients = initial_typical_ingredients

			initial_typical_ingredients.each do |ti|
				next if uniq_ingredients.select{|i|i.name.downcase == ti[:name]}.length == 0
				ordered_typical_ingredients.reject!{|oti| oti[:name] == ti[:name]}
				ordered_typical_ingredients.push(ti)
			end

			return ordered_typical_ingredients

		end


	end

	def create_stock(user_id = nil, stock_params = nil)
		return unless (current_user != nil || user_id != nil) && stock_params != nil

		if user_id == nil && current_user != nil
			user_id = current_user.id
		end

		updated_ingredient_id = nil

		if params.has_key?(:stock) && params[:stock].has_key?(:ingredient_id) && params[:stock][:ingredient_id].to_i == 0 && params[:stock][:ingredient_id].class == String
			if params[:stock].has_key?(:unit_id) && params[:stock][:unit_id].to_i != 0
				unit_id = params[:stock][:unit_id]
			else
				unit_id = Unit.find_by(name: "gram").id
			end

			ingredient = Ingredient.where('lower(name) = ?', params[:stock][:ingredient_id].downcase).first
			if ingredient == nil
				ingredient = Ingredient.create(name: params[:stock][:ingredient_id].humanize, unit_id: unit_id)
				UserMailer.admin_ingredient_add_notification(User.find(user_id), ingredient).deliver_now
				Ingredient.reindex
			end

			updated_ingredient_id = ingredient.id

		end

		@stock = Stock.new(stock_params)

		if params.has_key?(:stock) && params[:stock].has_key?(:ingredient_id) && params[:stock][:ingredient_id].to_i == 0 && params[:stock][:ingredient_id].class == String
			if updated_ingredient_id != nil
				@stock.update_attributes(
					ingredient_id: updated_ingredient_id
				)
			end
		end

		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])

		@cupboards = user_cupboards(User.find(user_id))

		if (params.has_key?(:id) && @cupboards.map(&:id).include?(cupboard_id_hashids.decode(params[:id]).first))
			@stock.update_attributes(
				cupboard_id: cupboard_id_hashids.decode(params[:id]).first
			)
		elsif @cupboards.map(&:id).include?(cupboard_id_hashids.decode(params[:stock][:cupboard_id]).first)
			@stock.update_attributes(
				cupboard_id: cupboard_id_hashids.decode(params[:stock][:cupboard_id]).first
			)
		else
			@stock.update_attributes(
				cupboard_id: @cupboards.first
			)
		end

		if @stock.save
			update_recipe_stock_matches(@stock[:ingredient_id])
			StockUser.create(
				stock_id: @stock.id,
				user_id: current_user[:id]
			)
			flash[:notice] = %Q[Just added #{serving_description(@stock)} to <a href="#{cupboards_path}">your cupboards</a>]
			return @stock
		else
			return nil
		end
	end

	def validate_cupboard_id(user_id = nil, encoded_cupboard_id = nil)
		return unless (current_user != nil || user_id != nil)

		if user_id == nil && current_user != nil
			user_id = current_user.id
		end

		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		@cupboards = user_cupboards(User.find(user_id))

		cupboard_id = @cupboards.first.id
		if encoded_cupboard_id != nil && @cupboards.map(&:id).include?(cupboard_id_hashids.decode(encoded_cupboard_id).first)
			cupboard_id = cupboard_id_hashids.decode(encoded_cupboard_id)
		end

		validated_encoded_cupboard_id = cupboard_id_hashids.encode(cupboard_id)
		return {original: cupboard_id, encoded: validated_encoded_cupboard_id}
	end

	def destroy_old_stock(user = nil)
		return if user == nil
		all_user_stock = user_stock(user, true)
		out_of_date_stock = all_user_stock.select{|s| s.use_by_date <= Date.current - stock_date_limit.days}
		out_of_date_stock.map{|s| s.destroy}
	end
end

