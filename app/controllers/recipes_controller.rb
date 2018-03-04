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
		@recipe = Recipe.find(params[:id])		
    if type == "favourite"
      current_user.favourites << @recipe
      redirect_back fallback_location: root_path, notice: 'You favourited #{@recipe.title}'

    elsif type == "unfavourite"
      current_user.favourites.delete(@recipe)
      redirect_back fallback_location: root_path, notice: 'Unfavourited #{@recipe.title}'

    else
      # Type missing, nothing happens
      redirect_back fallback_location: root_path, notice: 'Nothing happened.'
    end
  end
	private 
		def recipe_params 
			params.require(:recipe).permit(:user_id, :title, :description, portions_attributes:[:id, :amount, :_destroy]) 
		end
end
