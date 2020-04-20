include IngredientsHelper
class PlannerRecipe < ApplicationRecord
	# after_commit :update_planner_portions

	belongs_to :recipe
	belongs_to :user
	belongs_to :planner_shopping_list
	has_many :planner_shopping_list_portions, dependent: :destroy
	has_many :stocks, dependent: :nullify

	# private
	# 	def delete_all_planner_portions_and_create_new(planner_shopping_list = nil)
	# 		return if planner_shopping_list == nil || user_signed_in? == false

	# 		## Destroy all planner portions
	# 		planner_shopping_list.planner_shopping_list_portions.destroy_all

	# 		## Loop over all planner recipes
	# 		planner_shopping_list.planner_recipes.each do |pr|

	# 			## Ignore old planner recipes
	# 			next if pr.date < Date.current

	# 			## Loop over all associated recipe portions
	# 			pr.recipe.portions.each do |rp|

	# 				## Ignore water portions
	# 				next if rp.ingredient.name.downcase == 'water'

	# 				## Create new planner portions using the recipe portion as template
	# 				PlannerShoppingListPortion.create(
	# 					user_id: current_user.id,
	# 					planner_recipe_id: pr.id,
	# 					ingredient_id: rp.ingredient_id,
	# 					unit_id: rp.unit_id,
	# 					amount: rp.amount,
	# 					planner_shopping_list_id: planner_shopping_list.id,
	# 					date: planner_recipe.date + get_ingredient_use_by_date_diff(rp.ingredient),
	# 					checked: false ### TODO: track state of checked portions
	# 				)
	# 			end
	# 		end
	# 	end

	# 	def delete_all_combi_planner_portions_and_create_new(planner_shopping_list = nil)
	# 		return if planner_shopping_list == nil || user_signed_in? == false
	# 		## Delete all planner combi portions
	# 		planner_shopping_list.combi_planner_shopping_list_portions.destroy_all

	# 		## Find all planner portions with same ingredient
	# 		planner_shopping_list.combi_planner_shopping_list_portions.group_by{|p| p.ingredient_id}.select{|k,v| v.length > 1}.each {|ing_id, portion_group|

	# 		combi_amount = serving_addition(portion_group)
	# 		combi_portion = CombiPlannerShoppingListPortion.create(
	# 			user_id: current_user.id,
	# 			planner_shopping_list_id: planner_shopping_list.id,
	# 			ingredient_id: ing_id,
	# 			amount: combi_amount ? combi_amount[:amount] : nil,
	# 			unit_id: combi_amount ? combi_amount[:unit_id] : nil,
	# 			date: portion_group.sort_by{|p| p.planner_recipe.date}.first.date,
	# 			checked: portion_group.count{|p| p.checked == false} > 0 ? false : true
	# 		)

	# 		portion_group.each do |p|
	# 			p.update_attributes(
	# 				combi_planner_shopping_list_portion_id: combi_portion.id
	# 			)
	# 		end

	# 	}

	# 	### TODO --- instead of always trying to figure out what to items added together is for combi portion
	# 	### 			   could just show those two amounts grouped eg Carrots [100g + 2 small]
	# 	### 				 if combi portion amount is nil, output individual portion amount instead?
	# 	###			 --- Render combi portion as wrapper/parent to other portions
	# 	###					 - if combi portion amount is known then show it and hide other portions,
	# 	###					 other portions can be shown and checked individually
	# 	###							if combi portion is checked - both other portions are checked also
	# 	###					 - if combi portion not know, still wrapped with combi portion,
	# 	### 					but expanded to show other portion amounts

	# 	end

	# 	def update_planner_portions
	# 		planner_shopping_list = self.planner_shopping_list

	# 		delete_all_planner_portions_and_create_new(planner_shopping_list)
	# 		delete_all_combi_planner_portions_and_create_new(planner_shopping_list)
	# 	end
end