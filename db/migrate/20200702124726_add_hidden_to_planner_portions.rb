class AddHiddenToPlannerPortions < ActiveRecord::Migration[5.1]
  def change
    add_column :planner_shopping_list_portions, :hidden, :boolean, default: false
    add_column :combi_planner_shopping_list_portions, :hidden, :boolean, default: false
  end
end
