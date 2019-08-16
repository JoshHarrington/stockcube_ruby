class RemoveRecipeFromPlannerShoppingList < ActiveRecord::Migration[5.1]
  def change
    remove_column :planner_shopping_lists, :recipe_id
  end
end
