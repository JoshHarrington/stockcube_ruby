class AddGenIdToShoppingList < ActiveRecord::Migration[5.1]
  def change
    add_column :planner_shopping_lists, :gen_id, :string
    add_index :planner_shopping_lists, :gen_id, unique: true
  end
end
