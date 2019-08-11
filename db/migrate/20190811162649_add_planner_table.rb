class AddPlannerTable < ActiveRecord::Migration[5.1]
  def change
    create_table :planner_recipes do |t|
      t.belongs_to :recipe, foreign_key: true
      t.date :date

      t.timestamps
    end
  end
end
