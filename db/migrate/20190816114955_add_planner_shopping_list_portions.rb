class AddPlannerShoppingListPortions < ActiveRecord::Migration[5.1]
  def change
    create_table :planner_shopping_list_portions do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :planner_shopping_list, foreign_key: true, index: {:name => "index_planner_shopping_list__portions"}
      t.belongs_to :planner_recipe, foreign_key: true
      t.belongs_to :ingredient, foreign_key: true
      t.references :unit, foreign_key: true

      t.decimal :amount

      t.timestamps
    end
  end
end
