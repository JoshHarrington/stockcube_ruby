desc "This task is called by the Heroku scheduler add-on"

task :send_check_email => :environment do
	week_start = Time.now.beginning_of_day
	week_end = week_start + 7.days
	stock_going_off_array = []
	User.where.not(confirmed_at: nil).each do |user|
		if user.user_setting.notify && user.user_setting.notify_day == Time.now.wday
			user.cupboards.where(setup: false, hidden: false).each do |cupboard|
				stock_going_off_array.push(cupboard.stocks.where("use_by_date BETWEEN ? AND ?", week_start, week_end).order(use_by_date: :desc).map(&:id))
			end
			if stock_going_off_array.length > 0
				stock_going_off = Stock.find(stock_going_off_array)
				user.send_checking_email_with_scheduler(stock_going_off)
			end
		end
	end
end

task :remove_old_stock_and_portions => :environment do
	User.all.each do |u|
		u.remove_out_of_date_stock
		u.remove_old_planner_portions
	end
end

task :reindex_recipes_and_ingredients => :environment do
	Ingredient.reindex
	Recipe.reindex
end
