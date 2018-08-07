class UpdateStockToIncludeUnitId < ActiveRecord::Migration[5.1]
  def change
    rename_column :stocks, :unit_number, :unit_id
  end
end
