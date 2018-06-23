class RenameAmountColumnInShoppingListPortions < ActiveRecord::Migration[5.1]
  def change
    rename_column :shopping_list_portions, :amount, :portion_amount
  end
end
