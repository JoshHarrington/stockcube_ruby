class ChangePlannerShoppingListToPlannerShoppingLists < ActiveRecord::Migration[5.1]
  def change
    rename_table :planner_shopping_list, :planner_shopping_lists
  end
end
