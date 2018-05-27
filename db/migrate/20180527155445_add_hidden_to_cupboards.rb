class AddHiddenToCupboards < ActiveRecord::Migration[5.1]
  def change
    add_column :cupboards, :hidden, :boolean, default: false
  end
end
