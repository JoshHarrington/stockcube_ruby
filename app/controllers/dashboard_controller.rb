class DashboardController < ApplicationController
	include PlannerShoppingListHelper
	def dash
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])
		@recipes = Recipe.first(8)
		@planner_recipes = current_user.planner_recipes.select{|pr| pr.date > Date.current - 1.day && pr.date < Date.current + 7.day}.sort_by{|pr| pr.date}
	end

	def recipe_add_to_planner
		current_user.planner_shopping_lists.first.update_attributes(
			ready: false
		)
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])
		return unless params.has_key?(:recipe_id) && Recipe.exists?(@recipe_id_hash.decode(params[:recipe_id]).first)
		recipe = Recipe.find(@recipe_id_hash.decode(params[:recipe_id]).first)

		return unless recipe && params.has_key?(:planner_date) && Date.parse(@planner_recipe_date_hash.decode(params[:planner_date]).first.to_s).to_date && (recipe.public == true || recipe.user == current_user)
		recipe_id = recipe.id
		user_id = current_user.id
		date_string = Date.parse(@planner_recipe_date_hash.decode(params[:planner_date]).first.to_s).to_date

		planner_recipe = PlannerRecipe.find_or_create_by(
			user_id: user_id,
			recipe_id: recipe_id,
			date: date_string
		)

		if recipe.portions.length > 0
			add_planner_recipe_to_shopping_list(planner_recipe)
		end

		current_user.planner_shopping_lists.first.update_attributes(
			ready: true
		)

	end

	def recipe_update_in_planner
		current_user.planner_shopping_lists.first.update_attributes(
			ready: false
		)

		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])
		return unless params.has_key?(:recipe_id) && Recipe.exists?(@recipe_id_hash.decode(params[:recipe_id]).first)
		recipe = Recipe.find(@recipe_id_hash.decode(params[:recipe_id]).first)

		return unless recipe && params.has_key?(:new_date) && Date.parse(@planner_recipe_date_hash.decode(params[:new_date]).first.to_s).to_date && (recipe.public == true || recipe.user == current_user)
		recipe_id = recipe.id
		user_id = current_user.id
		new_date = Date.parse(@planner_recipe_date_hash.decode(params[:new_date]).first.to_s).to_date


		return unless params.has_key?(:old_date) && Date.parse(@planner_recipe_date_hash.decode(params[:old_date]).first.to_s).to_date
		old_date = Date.parse(@planner_recipe_date_hash.decode(params[:old_date]).first.to_s).to_date

		PlannerRecipe.find_or_create_by(
			user_id: user_id,
			recipe_id: recipe.id,
			date: old_date
		).update_attributes(
			date: new_date
		)
		current_user.planner_shopping_lists.first.update_attributes(
			ready: true
		)
	end

	def delete_recipe_from_planner
		current_user.planner_shopping_lists.first.update_attributes(
			ready: false
		)
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])
		return unless params.has_key?(:recipe_id) && Recipe.exists?(@recipe_id_hash.decode(params[:recipe_id]).first)
		recipe = Recipe.find(@recipe_id_hash.decode(params[:recipe_id]).first)

		return unless recipe && params.has_key?(:date) && Date.parse(@planner_recipe_date_hash.decode(params[:date]).first.to_s).to_date && (recipe.public == true || recipe.user == current_user)
		recipe_id = recipe.id
		user_id = current_user.id
		date = Date.parse(@planner_recipe_date_hash.decode(params[:date]).first.to_s).to_date


		planner_recipe = PlannerRecipe.find_by(
			user_id: user_id,
			recipe_id: recipe_id,
			date: date
		)

		combine_divided_stock_after_planner_recipe_delete(planner_recipe)

		planner_recipe.destroy

		current_user.planner_shopping_lists.first.update_attributes(
			ready: true
		)
	end

	def get_shopping_list_content
		if current_user.planner_shopping_lists.first.ready == true

			planner_recipes = current_user.planner_recipes.select{|pr| pr.date > Date.current - 1.day && pr.date < Date.current + 7.day}.sort_by{|pr| pr.date}.map{|pr| pr.planner_shopping_list_portions.reject{|p|p.ingredient.name.downcase == 'water'}.map{|p| {"planner_recipe_id": pr.id, "shopping_list_portion_id": p.id, "planner_recipe_description": pr.recipe.title + ' (' + pr.date.to_s(:short) + ')', "portion_description": p.amount.to_f.to_s + ' ' + p.unit.name + ' ' + p.ingredient.name} } }

			respond_to do |format|
				format.json { render json: planner_recipes.as_json}
				format.html { redirect_to dashboard_path }
			end

		else
			respond_to do |format|
				format.json { render json: [].as_json, status: 202}
				format.html { redirect_to dashboard_path }
			end
		end
	end
end