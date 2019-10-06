class PlannerPortionWrapper < ApplicationRecord
  belongs_to :user
  belongs_to :ingredient
	belongs_to :planner_shopping_list
	has_one :combi_planner_shopping_list_portion, dependent: :nullify
	has_one :planner_shopping_list_portion, dependent: :nullify

	belongs_to :unit

  validates :amount, presence: true

end
