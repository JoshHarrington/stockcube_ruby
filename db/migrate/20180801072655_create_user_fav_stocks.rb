class CreateUserFavStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :user_fav_stocks do |t|
      t.integer :ingredient_id
      t.integer :stock_amount
      t.integer :unit_id
      t.integer :user_id
      t.integer :standard_use_by_limit

      t.timestamps
    end
  end
end
