class DashboardController < ApplicationController
	def dash
		@recipes = Recipe.first(8)
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])
	end

	def recipe_add_to_planner
		Rails.logger.debug params
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])

		return unless params.has_key?(:recipe_id) && Recipe.exists?(@recipe_id_hash.decode(params[:recipe_id]).first)
		recipe = Recipe.find(@recipe_id_hash.decode(params[:recipe_id]).first)

		return unless recipe && params.has_key?(:planner_date) && Date.parse(@planner_recipe_date_hash.decode(params[:planner_date]).first.to_s).to_date && (recipe.public == true || recipe.user == current_user)
		recipe_id = recipe.id
		user_id = current_user.id
		date_string = Date.parse(@planner_recipe_date_hash.decode(params[:planner_date]).first.to_s).to_date

		if params.has_key?(:planner_id) && PlannerRecipe.exists?(@planner_recipe_date_hash.decode(params[:planner_id].first))
			PlannerRecipe.find(
				@planner_recipe_date_hash.decode(params[:planner_id].first)
			).update_attributes(
				user_id: user_id,
				recipe_id: recipe_id,
				date: date_string
			)
		else
			PlannerRecipe.find_or_create_by(
				user_id: user_id,
				recipe_id: recipe_id,
				date: date_string
			)
		end

	end
end