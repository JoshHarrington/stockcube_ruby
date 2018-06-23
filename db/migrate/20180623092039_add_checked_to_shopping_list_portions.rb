class AddCheckedToShoppingListPortions < ActiveRecord::Migration[5.1]
  def change
    add_column :shopping_list_portions, :checked, :boolean, default: false
  end
end
