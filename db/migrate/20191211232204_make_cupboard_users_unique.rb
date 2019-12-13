class MakeCupboardUsersUnique < ActiveRecord::Migration[5.1]
  def change
    add_index :cupboard_users, [:cupboard_id, :user_id], :unique => true
  end
end
