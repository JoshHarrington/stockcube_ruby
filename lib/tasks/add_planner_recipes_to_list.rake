desc "Regenerate shopping list gen ids"

task :add_planner_recipes_to_list => :environment do

	User.all.each do |u|
		planner_shopping_list = PlannerShoppingList.find_or_create_by(
			user_id: u.id,
			ready: true
		)
		u.planner_recipes.map{|r|r.update_attributes(
			planner_shopping_list_id: planner_shopping_list.id
		)}
	end

end