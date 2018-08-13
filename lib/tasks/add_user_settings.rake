desc "This task adds settings for all users"

task :add_settings_for_users => :environment do
	User.all.each do |user|
		UserSetting.find_or_create_by(
			user_id: user.id,
			notify_day: 0
		)
	end
end