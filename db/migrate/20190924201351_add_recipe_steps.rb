class AddRecipeSteps < ActiveRecord::Migration[5.1]
  def change
    create_table :recipe_steps do |t|
      t.belongs_to :recipe, index: true, foreign_key: true
      t.integer :number

      t.timestamps
    end
  end
end
