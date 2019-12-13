class CombiPlannerShoppingListPortion < ApplicationRecord

	has_many 	 :planner_shopping_list_portions, dependent: :nullify

  belongs_to :user
  belongs_to :ingredient
	belongs_to :planner_shopping_list
	belongs_to :unit
	belongs_to :planner_portion_wrapper, optional: true

  validates :amount, presence: true

end
