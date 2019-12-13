class AddDateToPlannerPortions < ActiveRecord::Migration[5.1]
  def change
    add_column :planner_shopping_list_portions, :date, :date
  end
end
