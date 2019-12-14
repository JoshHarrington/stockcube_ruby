class IngredientsController < ApplicationController
	before_action :authenticate_user!
	before_action :admin_user

	include UnitsHelper

	def index
		@ingredients = Ingredient.all
	end
	def show
		@ingredient = Ingredient.find(params[:id])
		@recipes = @ingredient.recipes
		@cupboards = @ingredient.cupboards
		@portions = @ingredient.portions
	end
	def new
    @ingredient = Ingredient.new
		@units = unit_list()
  end
  def create
		@ingredient = Ingredient.new(ingredient_params)
		@units = unit_list()
    if @ingredient.save
			redirect_to ingredients_path
			Ingredient.reindex
    else
      render 'new'
    end
	end
	def edit
		@ingredient = Ingredient.find(params[:id])
		@portions = @ingredient.portions
		@units = unit_list()
	end
	def update
		@ingredient = Ingredient.find(params[:id])
		@units = unit_list()

		@portions = @ingredient.portions
		if @ingredient.update(ingredient_params)
			redirect_to ingredients_path
			Ingredient.reindex
		else
			render 'edit'
		end
	end

	def default_size_update
	end

	protected
		def ingredient_params
			params.require(:ingredient).permit(:name, :searchable, :vegan, :vegetarian, :gluten_free, :dairy_free, :kosher, :unit_id)
		end

		# Confirms an admin user.
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end

end


