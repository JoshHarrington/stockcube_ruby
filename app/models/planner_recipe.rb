class PlannerRecipe < ApplicationRecord
	belongs_to :recipe
	belongs_to :user
	belongs_to :planner_shopping_list
	has_many :planner_shopping_list_portions, dependent: :delete_all
	has_many :stocks, dependent: :nullify
end