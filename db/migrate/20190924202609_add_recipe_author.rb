class AddRecipeAuthor < ActiveRecord::Migration[5.1]
  def change
    create_table :recipe_author do |t|
      t.belongs_to :recipe, index: true, foreign_key: true
      t.string :name
      t.string :link

      t.timestamps
    end
  end
end
