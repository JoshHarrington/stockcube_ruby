class UpdateForeignKeys < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key "combi_planner_shopping_list_portions", "ingredients"
    add_foreign_key "combi_planner_shopping_list_portions", "ingredients", dependent: :delete_all
    remove_foreign_key "combi_planner_shopping_list_portions", "planner_shopping_lists"
    add_foreign_key "combi_planner_shopping_list_portions", "planner_shopping_lists", dependent: :delete_all
    remove_foreign_key "combi_planner_shopping_list_portions", "units"
    add_foreign_key "combi_planner_shopping_list_portions", "units", dependent: :nullify
    remove_foreign_key "combi_planner_shopping_list_portions", "users"
    add_foreign_key "combi_planner_shopping_list_portions", "users", dependent: :destroy_all
    remove_foreign_key "default_ingredient_sizes", "ingredients"
    add_foreign_key "default_ingredient_sizes", "ingredients", dependent: :delete_all
    remove_foreign_key "default_ingredient_sizes", "units"
    add_foreign_key "default_ingredient_sizes", "units", dependent: :delete_all
    remove_foreign_key "planner_recipes", "planner_shopping_lists"
    add_foreign_key "planner_recipes", "planner_shopping_lists", dependent: :delete_all
    remove_foreign_key "planner_recipes", "recipes"
    add_foreign_key "planner_recipes", "recipes", dependent: :delete_all
    remove_foreign_key "planner_recipes", "users"
    add_foreign_key "planner_recipes", "users", dependent: :destroy_all
    remove_foreign_key "planner_shopping_list_portions", "combi_planner_shopping_list_portions"
    add_foreign_key "planner_shopping_list_portions", "combi_planner_shopping_list_portions", dependent: :nullify
    remove_foreign_key "planner_shopping_list_portions", "ingredients"
    add_foreign_key "planner_shopping_list_portions", "ingredients", dependent: :delete_all
    remove_foreign_key "planner_shopping_list_portions", "planner_recipes"
    add_foreign_key "planner_shopping_list_portions", "planner_recipes", dependent: :delete_all
    remove_foreign_key "planner_shopping_list_portions", "planner_shopping_lists"
    add_foreign_key "planner_shopping_list_portions", "planner_shopping_lists", dependent: :delete_all
    remove_foreign_key "planner_shopping_list_portions", "units"
    add_foreign_key "planner_shopping_list_portions", "units", dependent: :nullify
    remove_foreign_key "planner_shopping_list_portions", "users"
    add_foreign_key "planner_shopping_list_portions", "users", dependent: :destroy_all
    remove_foreign_key "planner_shopping_lists", "users"
    add_foreign_key "planner_shopping_lists", "users", dependent: :destroy_all
    remove_foreign_key "recipe_steps", "recipes"
    add_foreign_key "recipe_steps", "recipes", dependent: :delete_all
    remove_foreign_key "shopping_lists", "users"
    add_foreign_key "shopping_lists", "users", dependent: :destroy_all
    remove_foreign_key "stocks", "planner_recipes"
    add_foreign_key "stocks", "planner_recipes", dependent: :nullify

    remove_foreign_key "stocks", "planner_shopping_list_portions"
    add_foreign_key "stocks", "planner_shopping_list_portions", dependent: :nullify

    remove_foreign_key "user_fav_stocks", "ingredients"
    add_foreign_key "user_fav_stocks", "ingredients", dependent: :delete
  end
end
