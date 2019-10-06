class AddWrapperToPlannerPortions < ActiveRecord::Migration[5.1]
  def change
    add_reference :combi_planner_shopping_list_portions, :planner_portion_wrapper, index: {:name => "index_combi_portion_wrapper"}
    add_reference :planner_shopping_list_portions, :planner_portion_wrapper, index: {:name => "index_single_portion_wrapper"}
  end
end
