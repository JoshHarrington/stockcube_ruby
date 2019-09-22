class AddDefaultColumnToStock < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :default, :boolean, null: false, default: false
    add_column :stocks, :use_by_date_diff, :integer, default: 14
  end
end
