class RenameUnitNumberToUnitIdForPortions < ActiveRecord::Migration[5.1]
  def change
    rename_column :portions, :unit_number, :unit_id
  end
end
