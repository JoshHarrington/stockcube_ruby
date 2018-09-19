desc "Remove all empty setup cupboards"

task :remove_old_setup_cupboards => :environment do

	User.all.each do |user|


			setup_cupboard_ids = CupboardUser.where(user_id: user[:id], accepted: true).map(&:cupboard_id)
			setup_cupboards = Cupboard.where(id: setup_cupboard_ids, setup: true, hidden: false)
			delete_old_setup_stock = Stock.where(cupboard_id: setup_cupboard_ids).where("use_by_date <= ?", Time.now - 4.days).delete_all
			cupboards_to_delete = setup_cupboards.map{|sc| sc.id if sc.stocks.length == 0 }
			Cupboard.find(cupboards_to_delete).map{|c| c.delete}

	end

end