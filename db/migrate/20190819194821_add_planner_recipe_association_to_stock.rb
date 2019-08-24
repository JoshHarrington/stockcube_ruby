class AddPlannerRecipeAssociationToStock < ActiveRecord::Migration[5.1]
  def change
    add_reference :stocks, :planner_recipe, index: true
    add_foreign_key :stocks, :planner_recipes
  end
end
