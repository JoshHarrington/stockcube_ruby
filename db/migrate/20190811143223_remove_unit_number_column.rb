class RemoveUnitNumberColumn < ActiveRecord::Migration[5.1]
  def change
    remove_column :units, :unit_number
  end
end
