class CreateShoppingListPortions < ActiveRecord::Migration[5.1]
  def change
    create_table :shopping_list_portions do |t|
      t.belongs_to :ingredient, index: true 
      t.belongs_to :shopping_list, index: true

      t.decimal :amount

      t.timestamps
    end
  end
end
