class CreateDefaultIngredientSizes < ActiveRecord::Migration[5.1]
  def change
    create_table :default_ingredient_sizes do |t|
      t.belongs_to :ingredient, index: true, foreign_key: true
      t.belongs_to :unit, index: true, foreign_key: true
      t.decimal :amount
      t.integer :use_by_date_diff, default: 14

      t.timestamps
    end
  end
end
