class CreateCupboards < ActiveRecord::Migration[5.1]
  def change
    create_table :cupboards do |t|
      t.string :location

      t.timestamps
    end
  end
end
