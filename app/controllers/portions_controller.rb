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
		@current_unit = @portion.unit

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
		@current_unit = @portion.unit

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

		if not params[:portion][:unit_id] == @current_unit_number
			@portion.update_attributes(
				unit_id: params[:portion][:unit_id]
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
			params.require(:portion).permit(:amount, :unit_id, :recipe_id, :ingredient_id)
		end
end