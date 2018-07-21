namespace :cupboard_users do
  desc "Check if cupboards are currently associated to a user, if yes create a new entry in the cupboard users table"
	task :add_cupboard_users => :environment do
		Cupboard.all.each do |cupboard|
			if cupboard.user_id != nil
				cupboard_user = CupboardUser.find_or_create_by(
					cupboard_id: cupboard.id,
					user_id: cupboard.user_id
				)
				cupboard_user.update_attributes(
					owner: true,
					accepted: true
				)
				Cupboard.find(cupboard.id).update_attribute(
					:user_id, nil
				)
			end
		end
	end
end
