class CreateFavouriteRecipes < ActiveRecord::Migration[5.1]
  def change
    create_table :favourite_recipes do |t|
      t.belongs_to :recipe, index: true 
      t.belongs_to :user, index: true 

      t.timestamps
    end
  end
end
