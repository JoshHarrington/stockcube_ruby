class CreateUserSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :user_settings do |t|
      t.integer :user_id
      t.boolean :notify, null: false, default: false

      t.timestamps
    end
  end
end
