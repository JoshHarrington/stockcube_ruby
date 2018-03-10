class CreateShoppingLists < ActiveRecord::Migration[5.1]
  def change
    create_table :shopping_lists do |t|
      t.belongs_to :user, foreign_key: true
      t.date :date_created

      t.timestamps
    end
  end
end
