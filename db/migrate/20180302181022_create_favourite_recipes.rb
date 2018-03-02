class CreateFavouriteRecipes < ActiveRecord::Migration[5.1]
  def change
    create_table :favourite_recipes do |t|
      t.integer :recipe_id
      t.integer :user_id

      t.timestamps
    end
  end
end
