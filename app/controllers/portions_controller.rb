class PortionsController < ApplicationController
	def show
		@portion = Portion.find(params[:id])
		@units =	@portion.units
	end
	def new
		@portion = Portion.new
		@ingredients = Ingredient.all.order('name ASC')
		@units = Unit.all
		@unit_select = []

		Rails.logger.debug params[:recipe_id]
		Rails.logger.debug Recipe.where(id: params[:recipe_id]).first

		@units.each do |unit|
			if unit.unit_number == 5
				@unit_select << unit
			elsif unit.unit_number == 8
				@unit_select << unit
			elsif unit.unit_number == 11
				@unit_select << unit
			elsif unit.unit_number == 22
				@unit_select << unit
			elsif unit.unit_number == 25
				@unit_select << unit
			end
		end
	end
	def create
		@portion = Portion.new(portion_params)
		@ingredients = Ingredient.all.order('name ASC')
		@units = Unit.all
		@unit_select = []

		@units.each do |unit|
			if unit.unit_number == 5
				@unit_select << unit
			elsif unit.unit_number == 8
				@unit_select << unit
			elsif unit.unit_number == 11
				@unit_select << unit
			elsif unit.unit_number == 22
				@unit_select << unit
			elsif unit.unit_number == 25
				@unit_select << unit
			end
		end

		if params[:ingredient][:name].present?
			@selected_ingredient_name = params[:ingredient][:name]
			@selected_ingredient = Ingredient.where(name: @selected_ingredient_name).first
			@selected_ingredient_id = @selected_ingredient.id
		elsif params[:ingredient_id].present?
			@selected_ingredient_id = params[:ingredient_id]
		end



		# if params[:recipe_id].present?
		# 	@selected_recipe_id = params[:recipe_id]
		# else
		# 	## should fail
		# end

		@portion_amount = params[:amount]
		@portion_unit = params[:unit_number]


		@portion.update_attributes(
			unit_number: @portion_unit,
			ingredient_id: @selected_ingredient_id
		)

		@recipe_for_portion = Recipe.where(id: params[:recipe_id]).first

    if @portion.save
      redirect_to recipe_path(@recipe_for_portion)
    else
			render 'new'
			flash[:danger] = "Make sure you select an ingredient"
    end
	end

	def edit
		@portion = Portion.find(params[:id])
	end
	def update
		@portion = Portion.find(params[:id])
		@recipe = @portion.recipe
      if @portion.update(portion_params)
        redirect_to recipe_path(@recipe)
      else
        render 'edit'
      end
	end
	private
		def portion_params
			params.require(:portion).permit(:amount, ingredients_attributes:[:id, :name, :image, :unit])
		end
end