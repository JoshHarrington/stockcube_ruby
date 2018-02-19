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
	private 
		def recipe_params 
			params.require(:recipe).permit(:title) 
		end
end
