class DropShoppingLists < ActiveRecord::Migration[5.1]
  def change
    drop_table :shopping_list_portions
    drop_table :shopping_list_recipes
    drop_table :shopping_lists
  end
end
