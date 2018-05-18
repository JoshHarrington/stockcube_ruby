class AddHiddenColumnToIngredients < ActiveRecord::Migration[5.1]
  def change
    add_column :ingredients, :hidden, :boolean, default: false
  end
end
