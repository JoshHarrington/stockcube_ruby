class ShoppingListPortionUnitNumberToUnitId < ActiveRecord::Migration[5.1]
  def change
    rename_column(:shopping_list_portions, :unit_number, :unit_id)
  end
end
