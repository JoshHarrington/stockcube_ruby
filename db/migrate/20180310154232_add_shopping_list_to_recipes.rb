class AddShoppingListToRecipes < ActiveRecord::Migration[5.1]
  def change
    add_reference :recipes, :shopping_list, foreign_key: true
  end
end
