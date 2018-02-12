class CreatePortions < ActiveRecord::Migration[5.1]
  def change
    create_table :portions do |t|
      t.belongs_to :meal, index: true 
      t.belongs_to :ingredient, index: true
      
      t.string :unit
      t.string :amount

      t.timestamps
    end
  end
end
