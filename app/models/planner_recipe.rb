class PlannerRecipe < ApplicationRecord
	belongs_to :recipe
	belongs_to :user
	has_many :planner_shopping_list_portions, dependent: :delete_all
end