desc "This task is called by the Heroku scheduler add-on"

task :send_check_email => :environment do
	admin_user = User.where(admin: true).first
	UserMailer.ingredient_out_of_date_notification(admin_user).deliver_now
end