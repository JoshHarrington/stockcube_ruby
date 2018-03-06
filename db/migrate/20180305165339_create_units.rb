class CreateUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :units do |t|
      t.string :name
      t.string :unit_type
      t.decimal :metric_ratio, :optional

      t.timestamps
    end
  end
end
