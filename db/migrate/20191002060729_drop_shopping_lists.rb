class DropShoppingLists < ActiveRecord::Migration[5.1]
  def change
    drop_table :shopping_list_portions do |t|
    end
    drop_table :shopping_list_recipes do |t|
    end
    drop_table :shopping_lists do |t|
    end
  end
end
