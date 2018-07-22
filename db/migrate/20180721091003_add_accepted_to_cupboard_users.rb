class AddAcceptedToCupboardUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :cupboard_users, :accepted, :boolean, null: false, default: false
  end
end
