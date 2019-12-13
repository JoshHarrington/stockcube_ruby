class SetRecipeStepNumberToDefaultToZero < ActiveRecord::Migration[5.1]
  def change
    change_column :recipe_steps, :number, :integer, :null => true, :default => 0
  end
end
