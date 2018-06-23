class AddColumnsToShoppingListPortions < ActiveRecord::Migration[5.1]
  def change
    add_column :shopping_list_portions, :stock_amount, :numeric
    add_column :shopping_list_portions, :in_cupboard, :boolean, default: false
    add_column :shopping_list_portions, :percent_in_cupboard, :numeric
    add_column :shopping_list_portions, :enough_in_cupboard, :boolean, default: false
    add_column :shopping_list_portions, :plenty_in_cupboard, :boolean, default: false
    add_column :shopping_list_portions, :checked, :boolean, default: false
  end
end
