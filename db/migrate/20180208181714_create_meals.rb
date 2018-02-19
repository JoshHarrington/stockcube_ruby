class CreateMeals < ActiveRecord::Migration[5.1]
  def change
    create_table :meals do |t|
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
