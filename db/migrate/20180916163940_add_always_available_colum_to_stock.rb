class AddAlwaysAvailableColumToStock < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :always_available, :boolean, null: false, default: false
  end
end
