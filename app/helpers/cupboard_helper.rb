module CupboardHelper
	def use_by_date(stock)
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
		stock_num = cupboard.stocks.select{|s| s.planner_recipe == nil && s.hidden == false && s.ingredient.name.downcase.to_s != "water" && s.use_by_date > Date.current - 4.day}.length
		if stock_num < 1
			return 'empty'
		end
	end
	def cupboard_stocks_selection_in_date(cupboard)
		@stocks = cupboard.stocks.select{|s| s.planner_recipe == nil && s.hidden == false && s.ingredient.name.downcase != 'water' && s.use_by_date > Date.current - 4.day}.sort_by{|s| s.use_by_date}
		return @stocks
	end
	def planner_stocks(planner_recipe_id)
		@stocks = PlannerRecipe.find(planner_recipe_id).stocks.select{|s| s.hidden == false && s.always_available == false && s.use_by_date > Date.current - 4.day}.sort_by{|s| s.use_by_date}
		return @stocks
	end
end
