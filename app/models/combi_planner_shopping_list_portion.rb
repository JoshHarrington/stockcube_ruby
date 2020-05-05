class CombiPlannerShoppingListPortion < ApplicationRecord

	# after_update :update_related_planner_portions_checked_state
	has_many :planner_shopping_list_portions, dependent: :nullify

  belongs_to :user
  belongs_to :ingredient
	belongs_to :planner_shopping_list
	belongs_to :unit, optional: true
	belongs_to :planner_portion_wrapper, optional: true

	# validates :amount, presence: true

	private
		# def update_related_planner_portions_checked_state
		# 	self.planner_shopping_list_portions.each do |portion|
		# 		portion.update_attributes(checked: self.checked)
		# 	end
		# end

		### getting into a loop with this
		### if a child portion is unchecked
		### it should make the combi portion as unchecked
		### but not delete any sibling portions

		### if a combi portion is unchecked
		###  - that should then uncheck both child portions

end
