class AddPlannerPortionIdToStock < ActiveRecord::Migration[5.1]
  def change
    add_reference :stocks, :planner_shopping_list_portion, index: true
    add_foreign_key :stocks, :planner_shopping_list_portions
  end
end
