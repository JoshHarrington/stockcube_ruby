class CreateCupboards < ActiveRecord::Migration[5.1]
  def change
    create_table :cupboards do |t|
      t.belongs_to :user, index: true
      
      t.string :location

      t.timestamps
    end
  end
end
