module CupboardHelper
	def _use_by_date(stock = nil)
		return "Date not found" if stock == nil
		days_from_now = (stock.use_by_date - Date.current).to_i
		weeks_from_now = (days_from_now / 7).floor
		months_from_now = (days_from_now / 30).floor
		if stock.use_by_date.today?
			return "Going out of date today!"
		elsif stock.use_by_date.future?
			if days_from_now > 30
				return "Use by date is more than " + pluralize(months_from_now, "month") + " away"
			elsif days_from_now > 6
				return "Use by date is more than " + pluralize(weeks_from_now, "week") + " away"
			else
				return "Use by date is " + pluralize(days_from_now, "day") + " away"
			end
		elsif days_from_now > -2
			return "Just out of date"
		else
			return "Out of date"
		end
	end
	def date_warning_class(stock)
		days_from_now = (stock.use_by_date - Date.current).to_i
		if days_from_now < 2 && days_from_now > -2
			return ' date-part-warning'
		elsif days_from_now <= -2
			return ' date-full-warning'
		end
	end
	def stock_unit(stock)
		return stock.unit
	end
	def cupboard_shared_class(cupboard)
		if cupboard.cupboard_users.length > 1
			return 'shared'
		end
	end
	def cupboard_empty_class(cupboard)
		stock_num = cupboard.stocks.select{|s| s.planner_recipe == nil && s.hidden == false && s.ingredient.name.downcase.to_s != "water" && s.use_by_date > Date.current - stock_date_limit.day}.length
		if stock_num < 1
			return 'empty'
		end
	end
	def cupboard_stocks_selection_in_date(cupboard)
		stocks = cupboard.stocks.select{|s| s.planner_shopping_list_portion_id == nil && s.hidden == false && s.ingredient.name.downcase != 'water' && s.use_by_date > Date.current - stock_date_limit.day}.sort_by{|s| [s.use_by_date, s.ingredient.name]}
		return stocks
	end
	def planner_stocks(planner_recipe)
		stock_from_planner_portions = planner_recipe.planner_shopping_list_portions
			.map{|p| p.stock}.compact
			.select{|s|s.hidden == false && s.always_available == false && s.use_by_date > Date.current - stock_date_limit.day}
			.sort_by{|s| s.use_by_date}
		return stock_from_planner_portions
	end

	def user_cupboards(user = nil)
		return if user == nil
		return user.cupboard_users.where(accepted: true)
			.select{|cu| cu.cupboard.setup == false && cu.cupboard.hidden == false }
			.map{|cu| cu.cupboard }.sort_by{|c| c.created_at}.reverse!
	end
	def first_cupboard(user = nil)
		return user_cupboards(user).first
	end


	def user_stock(user = nil, showPlannerPortionStock = false)
		return if user == nil

		cupboards = user_cupboards(user)

		if showPlannerPortionStock
			user_stock = user.stocks
				.where(cupboard_id: cupboards.map(&:id), hidden: false)
				.uniq
		else
			user_stock = user.stocks
				.where(cupboard_id: cupboards.map(&:id), planner_shopping_list_portion_id: nil, hidden: false)
				.uniq
		end


		return user_stock
	end

	def user_stock_multiples(user = nil)
		return if user == nil

		user_stock_multiples = user_stock(user)
			.group_by{|s|s.ingredient_id}.select{|i_id, v| v.length > 1 }.values.flatten

		return user_stock_multiples
	end

	def needed_stock(planner_recipe)
		planner_stock_ingredient_ids = planner_stocks(planner_recipe).map(&:ingredient_id).uniq
		return planner_recipe.recipe.portions.where.not(ingredient_id: planner_stock_ingredient_ids)
	end

	def recipe_portions_checked_portions(planner_recipe)
		return {
			recipe_portions_in_stock: planner_stocks(planner_recipe).length,
			recipe_portion_total: planner_recipe.recipe.portions.select{|p|p.ingredient.name.downcase != 'water'}.length
		}
	end

	def recipe_portions_in_stock_vs_total_float(planner_recipe)
		recipe_portions_checked_portions_hash = recipe_portions_checked_portions(planner_recipe)
		return recipe_portions_checked_portions_hash[:recipe_portions_in_stock] / recipe_portions_checked_portions_hash[:recipe_portion_total].to_f
	end

	def recipe_portions_in_stock_vs_total_percentage(planner_recipe)
		return recipe_portions_in_stock_vs_total_float(planner_recipe) * 100
	end


	def processed_cupboard_contents(_user = nil)
		return [] unless _user != nil || (defined?(user_signed_in?) && user_signed_in? != false)
		if defined?(user_signed_in?)
			if user_signed_in? == false
				user = _user
			else
				user = current_user
			end
		else
			user = _user
		end
		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		cupboard_sharing_hashids = Hashids.new(ENV['CUPBOARD_SHARING_ID_SALT'])
		delete_stock_hashids = Hashids.new(ENV['DELETE_STOCK_ID_SALT'])

		cupboards = user_cupboards(user)
		return cupboards.map{|c| {
			title: c.location,
			id: cupboard_id_hashids.encode(c.id),
			stock: cupboard_stocks_selection_in_date(c).length > 0 ? cupboard_stocks_selection_in_date(c).map{|s|
				{
					id: s.id,
					title: serving_description(s),
					href: edit_stock_path(s),
					fresh: s.use_by_date >= Time.zone.now,
					freshForTime: distance_of_time_in_words(Time.zone.now, s.use_by_date),
					encodedIdForDelete: delete_stock_hashids.encode(s.id)
				}
			} : [],
			newStockHref: stocks_new_path(cupboard_id: cupboard_id_hashids.encode(c.id)),
			customNewStockHref: stocks_custom_new_path(cupboard_id: cupboard_id_hashids.encode(c.id)),
			users: c.cupboard_users.select{|cu|cu.user != user}.length > 0 ? c.cupboard_users.select{|cu|cu.user != user}.map{|cu|cu.user.name}.to_sentence : nil,
			sharingPath: cupboard_share_path(cupboard_sharing_hashids.encode(c.id))
		}}
	end
end
