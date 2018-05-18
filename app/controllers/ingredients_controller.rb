class IngredientsController < ApplicationController
	before_action :logged_in_user
	before_action :admin_user

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
  end
  def create
    @ingredient = Ingredient.new(ingredient_params)
    if @ingredient.save
      redirect_to ingredients_path
    else
      render 'new'
    end
	end
	def edit
		@ingredient = Ingredient.find(params[:id])
		@portions = @ingredient.portions
	end
	def update
		@ingredient = Ingredient.find(params[:id])
		@portions = @ingredient.portions
			if @ingredient.update(ingredient_params)
				redirect_to ingredients_path
			else
				render 'edit'
			end
	end
	private
		def ingredient_params
			params.require(:ingredient).permit(:name, :image, :searchable, :unit, units_attributes:[:id, :unit_number, :name, :short_name, :unit_type, :_destroy])
		end

		# Confirms a logged-in user.
		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end

		# Confirms an admin user.
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end

end


