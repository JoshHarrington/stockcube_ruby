class AddContentToRecipeStep < ActiveRecord::Migration[5.1]
  def change
    add_column :recipe_steps, :content, :string
  end
end
