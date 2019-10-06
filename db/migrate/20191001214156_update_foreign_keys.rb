class UpdateForeignKeys < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key "combi_planner_shopping_list_portions", "ingredients"
    remove_foreign_key "combi_planner_shopping_list_portions", "planner_shopping_lists"
    remove_foreign_key "combi_planner_shopping_list_portions", "units"
    remove_foreign_key "combi_planner_shopping_list_portions", "users"
    remove_foreign_key "default_ingredient_sizes", "ingredients"
    remove_foreign_key "default_ingredient_sizes", "units"
    remove_foreign_key "planner_recipes", "planner_shopping_lists"
    remove_foreign_key "planner_recipes", "recipes"
    remove_foreign_key "planner_recipes", "users"
    remove_foreign_key "planner_shopping_list_portions", "combi_planner_shopping_list_portions"
    remove_foreign_key "planner_shopping_list_portions", "ingredients"
    remove_foreign_key "planner_shopping_list_portions", "planner_recipes"
    remove_foreign_key "planner_shopping_list_portions", "planner_shopping_lists"
    remove_foreign_key "planner_shopping_list_portions", "units"
    remove_foreign_key "planner_shopping_list_portions", "users"
    remove_foreign_key "planner_shopping_lists", "users"
    remove_foreign_key "recipe_steps", "recipes"
    remove_foreign_key "stocks", "planner_recipes"
    remove_foreign_key "stocks", "planner_shopping_list_portions"
    remove_foreign_key "user_fav_stocks", "ingredients"
  end
end
