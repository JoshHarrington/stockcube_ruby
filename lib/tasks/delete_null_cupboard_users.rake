desc "Remove all empty setup cupboards"

task :delete_null_cupboard_users => :environment do
	cupboard_ids = Cupboard.all.map(&:id)
	CupboardUser.where.not(cupboard_id: cupboard_ids).delete_all
end