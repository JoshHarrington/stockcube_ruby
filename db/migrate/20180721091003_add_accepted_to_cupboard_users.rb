class AddAcceptedToCupboardUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :cupboard_users, :accepted, :boolean, default: false
  end
end
