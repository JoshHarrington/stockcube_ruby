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
		if days_from_now.between?(2, -2)
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
		if cupboard.stocks.where(hidden: false).length == 0 || cupboard.stocks.empty?
			return 'empty'
		else
			stocks = cupboard.stocks.where(hidden: false).order(use_by_date: :desc)
			days_from_now = (stocks.first.use_by_date - Date.current).to_i
			if days_from_now <= -2
				return 'empty all-out-of-date'
			end
		end
	end
	def cupboard_stocks_selection(cupboard)
		@stocks = cupboard.stocks.where(hidden: false).order(use_by_date: :desc)
		return @stocks
	end
end
