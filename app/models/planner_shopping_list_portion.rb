class PlannerShoppingListPortion < ApplicationRecord
  belongs_to :user
  belongs_to :ingredient
	belongs_to :planner_shopping_list
	belongs_to :planner_recipe, dependent: :destroy

	belongs_to :unit

  validates :amount, presence: true

end
