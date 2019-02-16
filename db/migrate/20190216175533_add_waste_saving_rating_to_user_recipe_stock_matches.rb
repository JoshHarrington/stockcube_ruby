class AddWasteSavingRatingToUserRecipeStockMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :user_recipe_stock_matches, :waste_saving_rating, :decimal, default: 0
  end
end
