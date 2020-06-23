class Stock < ApplicationRecord
	before_destroy :uncheck_planner_portions

	belongs_to :cupboard
	belongs_to :ingredient
	belongs_to :unit
	belongs_to :planner_recipe, optional: true
	belongs_to :planner_shopping_list_portion, optional: true
	has_many :stock_users, dependent: :destroy
	has_many :users, through: :stock_users

	accepts_nested_attributes_for :ingredient,
																:reject_if => :all_blank
	accepts_nested_attributes_for :unit

	validates :ingredient_id, presence: {message: "Make sure you select an ingredient"}
	validates :amount, presence: {message: "Amount needed - can't be blank"}
	validates_numericality_of :amount, on: :create
	validates :use_by_date, presence: {message: "Make sure you select a date"}
	validates :unit_id, presence: {message: "Make sure you select a unit"}

	private
		def uncheck_planner_portions
			if self.planner_shopping_list_portion_id != nil
				planner_portion = self.planner_shopping_list_portion

				if planner_portion != nil
					planner_portion.update_attributes(
						checked: false
					)
					if planner_portion.combi_planner_shopping_list_portion != nil
						planner_portion.combi_planner_shopping_list_portion.destroy
					end
				end
			end
		end

end
