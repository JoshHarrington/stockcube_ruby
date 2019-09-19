desc "Regenerate shopping list gen ids"

task :regenerate_shopping_list_gen_ids => :environment do

	PlannerShoppingList.all.each do |sl|
		sl.regenerate_gen_id
	end

end