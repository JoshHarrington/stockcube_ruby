class CreateShoppingListRecipes < ActiveRecord::Migration[5.1]
  def change
    create_table :shopping_list_recipes do |t|
      t.belongs_to :recipe, index: true 
      t.belongs_to :shopping_list, index: true

      t.timestamps
    end
  end
end
