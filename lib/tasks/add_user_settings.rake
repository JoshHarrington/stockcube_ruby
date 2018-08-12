desc "This task adds settings for all users"

task :add_settings_for_users => :environment do
	User.all.each do |user|
		UserSetting.create(
			user_id: user.id
		)
	end
end