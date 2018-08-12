desc "This task is called by the Heroku scheduler add-on"

task :send_check_email => :environment do
	User.send_checking_email_with_scheduler
end