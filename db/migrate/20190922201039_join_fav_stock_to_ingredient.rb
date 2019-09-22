class JoinFavStockToIngredient < ActiveRecord::Migration[5.1]
  def change
    add_index :user_fav_stocks, :ingredient_id
    add_foreign_key :user_fav_stocks, :ingredients
  end
end
