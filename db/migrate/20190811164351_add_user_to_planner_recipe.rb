class AddUserToPlannerRecipe < ActiveRecord::Migration[5.1]
  def change
    add_reference :planner_recipes, :user, index: true
    add_foreign_key :planner_recipes, :users
  end
end
