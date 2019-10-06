class PlannerShoppingList < ApplicationRecord
	has_secure_token :gen_id

	belongs_to :user
	has_many :planner_recipes, dependent: :delete_all
	has_many :planner_shopping_list_portions, dependent: :delete_all
	has_many :combi_planner_shopping_list_portions, dependent: :delete_all
	has_many :planner_portion_wrappers, dependent: :delete_all
end