class CreateStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :stocks do |t|
      t.belongs_to :cupboard, index: true 
      t.belongs_to :ingredient, index: true

      t.timestamps
    end
  end
end
