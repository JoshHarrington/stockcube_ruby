class CreateShoppingListRecipes < ActiveRecord::Migration[5.1]
  def change
    create_table :shopping_list_recipes do |t|
      t.integer :recipe_id
      t.integer :shopping_list_id

      t.timestamps
    end
  end
end
