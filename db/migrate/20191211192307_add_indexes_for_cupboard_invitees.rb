class AddIndexesForCupboardInvitees < ActiveRecord::Migration[5.1]
  def change
    add_index :cupboard_invitees, :email
    add_index :cupboard_invitees, :cupboard_id
  end
end
