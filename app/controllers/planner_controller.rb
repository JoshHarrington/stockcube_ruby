class PlannerController < ApplicationController
	before_action :authenticate_user!, except: [:list]
	include PlannerShoppingListHelper
	include ServingHelper
	def index
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@planner_recipe_date_hash = Hashids.new(ENV['PLANNER_RECIPE_DATE_SALT'])
		planner_recipe_ids = current_user.planner_recipes.select{|pr| pr.date > Date.current - 4.days}.map{|pr| pr.recipe.id}
		@recipes = current_user.user_recipe_stock_matches.order(ingredient_stock_match_decimal: :desc).select{|u_r| u_r.recipe && u_r.recipe.portions.length != 0 && (u_r.recipe[:public] || u_r.recipe[:user_id] == current_user[:id])}[0..7].map{|u_r| u_r.recipe}.reject{|r| planner_recipe_ids.include?(r.id) }

		recipe_id_plus_planner_recipe_ids = @recipes.map(&:id) + planner_recipe_ids
		@fav_recipes = current_user.favourites.reject{|f| recipe_id_plus_planner_recipe_ids.include?(f.id) }.first(8)

		update_planner_shopping_list_portions
	end

	def list
		if params.has_key?(:gen_id) && PlannerShoppingList.find_by(gen_id: params[:gen_id]) != nil
			@shopping_list = PlannerShoppingList.find_by(gen_id: params[:gen_id])
		else
			redirect_to planner_path
		end

	end

	def recipe_add_to_planner
		current_user.planner_shopping_list.update_attributes(
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

		planner_recipe = PlannerRecipe.create(
			user_id: user_id,
			recipe_id: recipe_id,
			date: date_string,
			planner_shopping_list_id: current_user.planner_shopping_list.id
		)

		if recipe.portions.length > 0
			add_planner_recipe_to_shopping_list(planner_recipe)
		end

		update_planner_shopping_list_portions

		current_user.planner_shopping_list.update_attributes(
			ready: true
		)

	end

	def recipe_update_in_planner
		current_user.planner_shopping_list.update_attributes(
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
			date: old_date,
			planner_shopping_list_id: current_user.planner_shopping_list.id
		).update_attributes(
			date: new_date
		)

		update_planner_shopping_list_portions

		current_user.planner_shopping_list.update_attributes(
			ready: true
		)
	end

	def delete_recipe_from_planner
		current_user.planner_shopping_list.update_attributes(
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

		if planner_recipe.present?
			combine_divided_stock_after_planner_recipe_delete(planner_recipe)
			planner_recipe.destroy
			update_planner_shopping_list_portions
		end

		current_user.planner_shopping_list.update_attributes(
			ready: true
		)
	end

	def get_shopping_list_content
		if (current_user && current_user.planner_shopping_list.ready == true) || (params.has_key?(:gen_id) && PlannerShoppingList.find_by(gen_id: params[:gen_id]).present? && PlannerShoppingList.find_by(gen_id: params[:gen_id]).ready == true)

			if params.has_key?(:gen_id) && PlannerShoppingList.find_by(gen_id: params[:gen_id]).present? && PlannerShoppingList.find_by(gen_id: params[:gen_id]).ready == true
				shopping_list = PlannerShoppingList.find_by(gen_id: params[:gen_id])
			elsif current_user && current_user.planner_shopping_list.ready == true
				shopping_list = current_user.planner_shopping_list
			else
				return
			end

			shopping_list_portions = shopping_list_portions(shopping_list)

			if shopping_list_portions.length > 0
				formatted_shopping_list_portions = shopping_list_portions.sort_by{|p| p.ingredient.name}.map do |p|
					num_assoc_recipes = '1'
					if p.class.name == 'PlannerPortionWrapper'
						if p.combi_planner_shopping_list_portion != nil
							portion_type = 'wrapper'
							num_assoc_recipes = p.combi_planner_shopping_list_portion.planner_shopping_list_portions.length
							portion_note = 'Combi portion (' + num_assoc_recipes.to_s + ' recipes)'
						else
							portion_type = 'wrapper'
							recipe_title = p.planner_shopping_list_portion.planner_recipe.recipe.title
							portion_note = 'Recipe portion - ' + recipe_title
						end
					else
						if p.class.name == "CombiPlannerShoppingListPortion"
							portion_type = 'individual'
							num_assoc_recipes = p.planner_shopping_list_portions.length
							portion_note = 'Combi portion (' + num_assoc_recipes.to_s + ' recipes)'
						else
							portion_type = 'individual'
							portion_note = 'Recipe portion - ' + p.planner_recipe.recipe.title
						end
					end
					{
						"portion_type": portion_type,
						"portion_note": portion_note,
						"shopping_list_portion_id": planner_portion_id_hash.encode(p.id),
						"portion_description": standard_serving_description(p),
						"max_date": (Date.current + 2.weeks).strftime("%Y-%m-%d"),
						"min_date": Date.current.strftime("%Y-%m-%d"),
						"recipe_title": p.has_attribute?(:planner_recipe_id) && p.planner_recipe.recipe.present? ? p.planner_recipe.recipe.title.to_s : recipe_title.to_s,
						"checked": p.checked.to_s,
						"num_assoc_recipes": num_assoc_recipes
					}
				end
				shopping_list_output = [{"stats": {"checked_portions": checked_portions, "total_portions": shopping_list_portions.length}}, {"portions": formatted_shopping_list_portions }, {"gen_id": shopping_list.gen_id }]
			else
				shopping_list_output = []
			end

			respond_to do |format|
				format.json { render json: shopping_list_output.as_json}
				format.html { redirect_to planner_path }
			end

		else
			respond_to do |format|
				format.json { render json: [].as_json, status: 202}
				format.html { redirect_to planner_path }
			end
		end
	end
end