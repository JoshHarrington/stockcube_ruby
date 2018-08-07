class CreateShoppingListPortions < ActiveRecord::Migration[5.1]
  def change
    create_table :shopping_list_portions do |t|
      t.belongs_to :ingredient, index: true
      t.belongs_to :shopping_list, index: true

      t.integer :unit_number
      t.integer :recipe_number
      t.decimal :portion_amount

      t.timestamps
    end
  end
end
