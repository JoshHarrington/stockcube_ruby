class AddColumnsShoppingListPortions < ActiveRecord::Migration[5.1]
  def change
    add_column :shopping_list_portions, :unit_name, :string
  end
end
