class AddCupboardInviteesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :cupboard_invitees do |t|
      t.string :email
      t.bigint :cupboard_id

      t.timestamps
    end
  end
end
