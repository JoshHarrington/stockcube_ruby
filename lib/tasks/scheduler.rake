desc "This task is called by the Heroku scheduler add-on"

task :send_check_email => :environment do
	week_start = Time.now.beginning_of_day
	week_end = week_start + 7.days
	stock_going_off = []
	User.where(activated: true).each do |user|
		user.cupboards.where(setup: false, hidden: false).each do |cupboard|
			stock_going_off = cupboard.stocks.where("use_by_date BETWEEN ? AND ?", week_start, week_end)
		end
		if stock_going_off.length > 0
			user.send_checking_email_with_scheduler(stock_going_off)
		end
	end
end