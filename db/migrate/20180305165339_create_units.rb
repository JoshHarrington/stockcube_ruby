class CreateUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :units do |t|
      t.integer :unit_number
      
      t.string :name
      t.string :short_name
      t.string :unit_type
      t.decimal :metric_ratio

      t.timestamps
    end
  end
end
