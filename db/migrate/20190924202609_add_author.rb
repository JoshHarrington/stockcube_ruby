class AddAuthor < ActiveRecord::Migration[5.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.string :link

      t.timestamps
    end
  end
end
