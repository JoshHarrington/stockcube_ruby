class DashboardController < ApplicationController
	def dash
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])
		@recipes = Recipe.first(8)
	end

	def recipe_add_to_planner
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])
		return unless params.has_key?(:recipe_id) && Recipe.exists?(@recipe_id_hash.decode(params[:recipe_id]).first)
		recipe = Recipe.find(@recipe_id_hash.decode(params[:recipe_id]).first)

		return unless recipe && params.has_key?(:planner_date) && Date.parse(@planner_recipe_date_hash.decode(params[:planner_date]).first.to_s).to_date && (recipe.public == true || recipe.user == current_user)
		recipe_id = recipe.id
		user_id = current_user.id
		date_string = Date.parse(@planner_recipe_date_hash.decode(params[:planner_date]).first.to_s).to_date

		PlannerRecipe.find_or_create_by(
			user_id: user_id,
			recipe_id: recipe_id,
			date: date_string
		)

	end

	def recipe_update_in_planner
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
	end

	def delete_recipe_from_planner
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])
		return unless params.has_key?(:recipe_id) && Recipe.exists?(@recipe_id_hash.decode(params[:recipe_id]).first)
		recipe = Recipe.find(@recipe_id_hash.decode(params[:recipe_id]).first)

		return unless recipe && params.has_key?(:date) && Date.parse(@planner_recipe_date_hash.decode(params[:date]).first.to_s).to_date && (recipe.public == true || recipe.user == current_user)
		recipe_id = recipe.id
		user_id = current_user.id
		date = Date.parse(@planner_recipe_date_hash.decode(params[:date]).first.to_s).to_date

		PlannerRecipe.find_by(
			user_id: user_id,
			recipe_id: recipe_id,
			date: date
		).delete

	end
end