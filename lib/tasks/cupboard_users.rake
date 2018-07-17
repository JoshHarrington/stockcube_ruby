namespace :cupboard_users do
  desc "Check if cupboards are currently associated to a user, if yes create a new entry in the cupboard users table"
	task :add_cupboard_users => :environment do
		Cupboard.all.each do |cupboard|
			if cupboard.user_id != nil
				CupboardUser.create(
					cupboard_id: cupboard.id,
					user_id: cupboard.user_id,
					owner: true
				)
			end
		end
	end
end
