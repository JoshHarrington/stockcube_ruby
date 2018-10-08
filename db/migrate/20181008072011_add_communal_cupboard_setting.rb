class AddCommunalCupboardSetting < ActiveRecord::Migration[5.1]
  def change
    add_column :cupboards, :communal, :boolean, null: false, default: false
  end
end
