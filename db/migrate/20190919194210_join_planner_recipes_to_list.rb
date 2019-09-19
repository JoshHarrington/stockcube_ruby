class JoinPlannerRecipesToList < ActiveRecord::Migration[5.1]
  def change
    add_reference :planner_recipes, :planner_shopping_list, index: true
    add_foreign_key :planner_recipes, :planner_shopping_lists
  end
end
