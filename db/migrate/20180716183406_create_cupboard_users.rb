class CreateCupboardUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :cupboard_users do |t|
      t.belongs_to :cupboard, index: true
      t.belongs_to :user, index: true

      t.boolean :owner, null: false, default: false

      t.timestamps
    end
  end
end
