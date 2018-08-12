desc "This task is called by the Heroku scheduler add-on"

task :send_check_email => :environment do
	UserMailer.user_stock_check
end