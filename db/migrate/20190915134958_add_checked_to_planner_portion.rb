class AddCheckedToPlannerPortion < ActiveRecord::Migration[5.1]
  def change
    add_column :planner_shopping_list_portions, :checked, :boolean, null: false, default: false
  end
end
