class CreateIngredients < ActiveRecord::Migration[5.1]
  def change
    create_table :ingredients do |t|
			t.string :name
      t.string :image
      t.string :unit, :default => 'kg'
      
      t.timestamps
    end
  end
end
