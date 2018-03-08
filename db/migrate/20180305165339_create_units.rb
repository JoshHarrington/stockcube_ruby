class CreateUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :units do |t|
      t.integer :unit_number
      
      t.string :name
      t.string :short_name, :optional
      t.string :unit_type
      t.decimal :metric_ratio, :optional

      t.timestamps
    end
  end
end
