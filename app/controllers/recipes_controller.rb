class RecipesController < ApplicationController
	def index
    @recipes = Recipe.all
	end
	def show
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
		@ingredients = @recipe.ingredients
	end
	def new 
		@recipe = Recipe.new 
  end
  def create
    @recipe = Recipe.new(recipe_params)
    if @recipe.save
      redirect_to '/recipes'
    else
      render 'new'
    end
	end
	def edit
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
	end
	def update
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
      if @recipe.update(recipe_params)
        redirect_to @recipe
      else
        render 'edit'
      end
	end
	# Add and remove favourite recipes
  # for current_user
  def favourite
    type = params[:type]
    if type == "favourite"
      current_user.favourites << @recipe
      redirect_to :back, notice: 'You favourited #{@recipe.name}'

    elsif type == "unfavourite"
      current_user.favourites.delete(@recipe)
      redirect_to :back, notice: 'Unfavourited #{@recipe.name}'

    else
      # Type missing, nothing happens
      redirect_to :back, notice: 'Nothing happened.'
    end
  end
	private 
		def recipe_params 
			params.require(:recipe).permit(:title, :description, portions_attributes:[:id, :amount, :_destroy]) 
		end
end
