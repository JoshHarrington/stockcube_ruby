class CreatePortionWrapper < ActiveRecord::Migration[5.1]
  def change
    create_table :planner_portion_wrappers do |t|
      t.belongs_to :user, index: true
      t.belongs_to :planner_shopping_list, index: true
      t.belongs_to :ingredient, index: true
      t.belongs_to :unit, index: true
      t.decimal :amount
      t.integer :use_by_date_diff
      t.date :date
      t.boolean :checked

      t.timestamps
    end
  end
end
