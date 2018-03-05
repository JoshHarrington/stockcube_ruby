class CreatePortions < ActiveRecord::Migration[5.1]
  def change
    create_table :portions do |t|
      t.belongs_to :recipe, index: true 
      t.belongs_to :ingredient, index: true
      
      t.string :amount, :default => '0.1'
      t.string :unit, :default => 'g'

      t.timestamps
    end
  end
end
