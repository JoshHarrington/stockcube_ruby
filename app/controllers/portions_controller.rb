class PortionsController < ApplicationController
	before_action :authenticate_user!
	include UnitsHelper

	def show
		@portion = Portion.find(params[:id])
		@units =	@portion.units
	end
	def new
		if not params.has_key?(:recipe_id)
			redirect_back fallback_location: recipes_path, notice: "Looks like something went wrong adding that ingredient"
			return
		end
		@portion = Portion.new
		@ingredients = Ingredient.all.order('name ASC')
		@units = unit_list()
	end

	def create_from_post
		if !user_signed_in?

		end
	end


	def create
		@portion = Portion.new(portion_params)
		@ingredients = Ingredient.all.order('name ASC')
		@assoc_recipe = Recipe.find(params[:portion][:recipe_id])
		new_stuff_added = false


		if params[:portion].has_key?(:unit_id) && params[:portion][:unit_id].present?
			if params[:portion][:unit_id].to_i == 0
				new_unit_from_portion = Unit.find_or_create_by(name: params[:portion][:unit_id])
				@portion_unit = new_unit_from_portion.id
				new_stuff_added = true
			else
				@portion_unit = params[:portion][:unit_id]
			end
		else
			flash[:danger] = "Make sure you select or add a unit"
		end


		if params[:portion].has_key?(:ingredient_id) && params[:portion][:ingredient_id].present?
			if params[:portion][:ingredient_id].to_i == 0
				new_ingredient_from_portion = Ingredient.find_or_create_by(name: params[:portion][:ingredient_id], unit_id: (@portion_unit || 8))
				selected_ingredient_id = new_ingredient_from_portion.id
				new_stuff_added = true
			else
				selected_ingredient_id = params[:portion][:ingredient_id]
			end
			Ingredient.reindex
		else
			flash[:danger] = "Make sure you select an ingredient"
		end

		@portion.update_attributes(
			unit_id: @portion_unit,
			ingredient_id: selected_ingredient_id
		)

		if @portion.save
			redirect_to edit_recipe_path(@assoc_recipe.id, anchor: 'ingredient_' + @portion.id.to_s)
		else
			if params[:portion].has_key?(:recipe_id) && params[:portion][:recipe_id].to_s != ''
				redirect_to portions_new_path(recipe_id: params[:portion][:recipe_id])
			else
				redirect_to recipes_path
			end
			flash[:danger] = "Make sure you select an ingredient"
		end
	end

	private
		def portion_params
			params.require(:portion).permit(:amount, :unit_id, :recipe_id, :ingredient_id)
		end
end