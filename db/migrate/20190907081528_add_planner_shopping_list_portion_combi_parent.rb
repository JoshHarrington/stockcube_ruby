class AddPlannerShoppingListPortionCombiParent < ActiveRecord::Migration[5.1]
  def change
    add_reference :planner_shopping_list_portions, :combi_planner_sl_portion, index: {:name => "index_planner_shopping_list_portion_to_combi"}
    add_foreign_key :planner_shopping_list_portions, :combi_planner_sl_portions
  end
end
