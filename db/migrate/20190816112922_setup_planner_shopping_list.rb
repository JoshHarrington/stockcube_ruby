class SetupPlannerShoppingList < ActiveRecord::Migration[5.1]
  def change
    create_table :planner_shopping_list do |t|
      t.belongs_to :user, foreign_key: true
      t.references :recipe, foreign_key: true

      t.timestamps
    end
  end
end
