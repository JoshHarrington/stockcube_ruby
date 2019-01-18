class AddSetupToCupboards < ActiveRecord::Migration[5.1]
  def change
    add_column :cupboards, :setup, :boolean, default: false
  end
end
