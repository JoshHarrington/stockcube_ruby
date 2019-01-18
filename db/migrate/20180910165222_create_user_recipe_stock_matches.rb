class CreateUserRecipeStockMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :user_recipe_stock_matches do |t|
      t.integer :user_id
      t.integer :recipe_id
      t.decimal :ingredient_stock_match_decimal
      t.integer :num_ingredients_total
      t.integer :num_stock_ingredients
      t.integer :num_needed_ingredients

      t.timestamps
    end
  end
end
