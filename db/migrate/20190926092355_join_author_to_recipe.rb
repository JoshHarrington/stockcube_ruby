class JoinAuthorToRecipe < ActiveRecord::Migration[5.1]
  def change
    create_table :recipe_authors do |t|
      t.belongs_to :recipe
      t.belongs_to :author
      t.references :recipes, index: true, foreign_key: true
      t.references :authors, index: true, foreign_key: true
    end
  end
end
