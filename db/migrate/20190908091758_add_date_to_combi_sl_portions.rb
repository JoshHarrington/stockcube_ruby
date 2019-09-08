class AddDateToCombiSlPortions < ActiveRecord::Migration[5.1]
  def change
    add_column :combi_planner_shopping_list_portions, :date, :date
  end
end
