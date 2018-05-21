class PortionsController < ApplicationController
	def show
		@portion = Portion.find(params[:id])
		@units =	@portion.units
	end
	def new
		@portion = Portion.new
		@ingredients = Ingredient.all.order('name ASC')
		@unit_select = Unit.all
	end
	def create
		@portion = Portion.new(portion_params)
		@ingredients = Ingredient.all.order('name ASC')
		@assoc_recipe = Recipe.where(id: params[:recipe_id]).first
		@unit_select = Unit.all

		if params[:ingredient_id].present?
			@selected_ingredient_id = params[:ingredient_id]
		end

		@portion_amount = params[:amount]
		@portion_unit = params[:unit_number]

		@portion.update_attributes(
			unit_number: @portion_unit,
			recipe_id: params[:recipe_id],
			ingredient_id: @selected_ingredient_id
		)


		if @portion.save
			redirect_to edit_recipe_path(@assoc_recipe)
		else
			render 'new'
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
			params.require(:portion).permit(:amount, ingredients_attributes:[:id, :name, :image, :unit])
		end
end