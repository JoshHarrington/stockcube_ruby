module PlannerShoppingListHelper
	def add_planner_recipe_to_shopping_list(planner_recipe = nil)
		return if planner_recipe == nil
		planner_shopping_list = PlannerShoppingList.find_by_or_create(user_id: current_user.id)
		planner_recipe.recipe.portions.each do |p|
			PlannerShoppingListPortion.create(
				user_id: current_user.id,
				planner_recipe_id: planner_recipe.id,
				ingredient_id: p.ingredient_id,
				unit_id: p.unit_id,
				amount: p.amount,
				planner_shopping_list_id: planner_shopping_list.id
			)
		end
	end
end
