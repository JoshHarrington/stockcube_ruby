class PortionsController < ApplicationController
	def show
		@portion = Portion.find(params[:id])
		@units =	@portion.units
	end
	def new
		@portion = Portion.new
		@ingredients = Ingredient.all.order('name ASC')
		@unit_select = Unit.all.map{|u| u if u.name != nil }.compact
		# @unit_select = Unit.all.map{|u| u if u.name != nil }.compact.map{|u| {id: u.id, name: u.name.pluralize} }
	end
	def create
		@portion = Portion.new(portion_params)
		@ingredients = Ingredient.all.order('name ASC')
		@assoc_recipe = Recipe.find(params[:portion][:recipe_id])
		@unit_select = Unit.all.map{|u| u if u.name != nil }.compact

		if params[:ingredient_id].present?
			@selected_ingredient_id = params[:ingredient_id]
		end

		if @portion.save
			redirect_to edit_recipe_path(params[:portion][:recipe_id], anchor: 'ingredient_' + @portion.id.to_s)
		else
			if params.has_key?(:recipe_id) && params[:portion][:recipe_id].to_s != ''
				redirect_to portions_new_path(recipe_id: params[:portion][:recipe_id])
			else
				redirect_to recipes_path
			end
			flash[:danger] = "Make sure you select an ingredient"
		end
	end

	# def edit
	# 	@portion = Portion.find(params[:id])
	# end
	# def update
	# 	@portion = Portion.find(params[:id])
	# 	@recipe = @portion.recipe
  #     if @portion.update(portion_params)
  #       redirect_to recipe_path(@recipe)
  #     else
  #       render 'edit'
  #     end
	# end



	def edit
		@portion = Portion.find(params[:id])
		@recipes = Recipe.all
		@current_recipe = @portion.recipe
		@ingredients = Ingredient.all.order('name ASC')
		@current_ingredient = @portion.ingredient
		@current_ingredient_unit = @portion.ingredient.unit
		@current_ingredient_unit_number = @current_ingredient_unit.unit_number
		@current_unit_number = @portion.unit_number
		@current_unit = Unit.where(unit_number: @current_unit_number).first

		if @current_ingredient_unit.unit_type == "volume"
			@units_select = Unit.where(:unit_type => "volume")
		elsif @current_ingredient_unit.unit_type == "mass"
			@units_select = Unit.where(unit_type: "mass")
		else
			@units_select = Unit.where(unit_type: "other")
		end

		if @current_unit.unit_type == @current_ingredient_unit.unit_type
			@preselect_unit = @current_unit
		else
			@preselect_unit = @unit_select.first
		end
	end
	def update
		@portion = Portion.find(params[:id])
		@recipes = current_user.recipes
		@current_recipe = @portion.recipe
		@ingredients = Ingredient.all.order('name ASC')
		@current_ingredient = @portion.ingredient
		@current_ingredient_unit = @portion.ingredient.unit
		@current_ingredient_unit_number = @current_ingredient_unit.unit_number
		@current_unit_number = @portion.unit_number
		@current_unit = Unit.where(unit_number: @current_unit_number).first

		if not params[:recipe_id] == @current_recipe.id
			@portion.update_attributes(
				recipe_id: params[:recipe_id]
			)
			@current_recipe = recipe.where(id: params[:recipe_id]).first
		end

		if @current_ingredient_unit.unit_type == "volume"
			@units_select = Unit.where(:unit_type => "volume")
		elsif @current_ingredient_unit.unit_type == "mass"
			@units_select = Unit.where(unit_type: "mass")
		else
			@units_select = Unit.where(unit_type: "other")
		end

		if @current_unit.unit_type == @current_ingredient_unit.unit_type
			@preselect_unit = @current_unit
		else
			@preselect_unit = @units_select.first
		end

		if not params[:unit_number] == @current_unit_number
			@portion.update_attributes(
				unit_number: params[:unit_number]
			)
		end

		if @portion.update(portion_params)
			redirect_to edit_recipe_path(@current_recipe)
		else
			render 'edit'
		end
	end
	private
		def portion_params
			params.require(:portion).permit(:amount, :unit_number, :ingredient_id, :recipe_id)
		end
end