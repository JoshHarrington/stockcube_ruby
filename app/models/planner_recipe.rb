include IngredientsHelper
class PlannerRecipe < ApplicationRecord
	validates :date, :presence => true

	belongs_to :recipe
	belongs_to :user
	belongs_to :planner_shopping_list
	has_many :planner_shopping_list_portions, dependent: :destroy
	has_many :stocks, dependent: :nullify

end