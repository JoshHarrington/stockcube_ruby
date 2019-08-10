class PortionUnitNumberToUnitId < ActiveRecord::Migration[5.1]
  def change
    Portion.reset_column_information
    rename_column(:portions, :unit_number, :unit_id) if Portion.column_names.include?('unit_number')
  end
end
