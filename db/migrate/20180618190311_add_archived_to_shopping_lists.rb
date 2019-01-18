class AddArchivedToShoppingLists < ActiveRecord::Migration[5.1]
  def change
    add_column :shopping_lists, :archived, :boolean, default: false
  end
end
