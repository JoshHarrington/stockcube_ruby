class PlannerShoppingListPortion < ApplicationRecord
  belongs_to :user
  belongs_to :ingredient
	belongs_to :planner_shopping_list
	belongs_to :planner_recipe
	belongs_to :combi_planner_shopping_list_portion, optional: true
	belongs_to :planner_portion_wrapper, optional: true
	has_one :stock, dependent: :nullify

	belongs_to :unit

  validates :amount, presence: true

end
