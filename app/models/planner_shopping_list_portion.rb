class PlannerShoppingListPortion < ApplicationRecord
  belongs_to :user
  belongs_to :ingredient
	belongs_to :planner_shopping_list
	belongs_to :planner_recipe
	belongs_to :combi_planner_shopping_list_portion, optional: true
	has_one :stock

	belongs_to :unit

  validates :amount, presence: true

end
