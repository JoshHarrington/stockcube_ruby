class CreatePortions < ActiveRecord::Migration[5.1]
  def change
    create_table :portions do |t|
      t.belongs_to :recipe, index: true 
      t.belongs_to :ingredient, index: true
      
      t.integer :unit_number, :optional

      t.decimal :amount

      t.timestamps
    end
  end
end
