class AddReadyStateToPlannerShoppingList < ActiveRecord::Migration[5.1]
  def change
    add_column :planner_shopping_lists, :ready, :boolean, null: false, default: true
  end
end
