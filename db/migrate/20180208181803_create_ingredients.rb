class CreateIngredients < ActiveRecord::Migration[5.1]
  def change
    create_table :ingredients do |t|
			t.string :name

      t.boolean :vegan, default: false
      t.boolean :vegetarian, default: false
      t.boolean :gluten_free, default: false
      t.boolean :dairy_free, default: false
      t.boolean :kosher, default: false
      
      t.timestamps
    end
  end
end
