class RecipesController < ApplicationController
	include ActionView::Helpers::UrlHelper	

	before_action :logged_in_user, only: [:index, :edit]
	before_action :user_has_recipes, only: :index
	before_action :admin_user,     only: [:create, :new, :edit, :update]

	def index
		@recipes = current_user.favourites
		@fallback_recipes = Recipe.all.sample(4)
	end
	def search
		if params[:search]
			@recipes = Recipe.search(params[:search]).order("created_at DESC")
		else
			@recipes = Recipe.all.order('created_at DESC')
		end
		@fallback_recipes = Recipe.all.sample(4)
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
        redirect_to recipe_path(@recipe)
      else
        render 'edit'
      end
	end
	# Add and remove favourite recipes
  # for current_user
  def favourite
		type = params[:type]
		@recipe = Recipe.find(params[:id])		
		recipe_title = @recipe.title
    if type == "favourite"
			current_user.favourites << @recipe
			@string = "Added the \"#{link_to(@recipe.title, recipe_path(@recipe))}\" recipe to favourites"
      redirect_back fallback_location: root_path, notice: @string

    elsif type == "unfavourite"
			current_user.favourites.delete(@recipe)
			@string = "Removed the \"#{link_to(@recipe.title, recipe_path(@recipe))}\" recipe from favourites"
			redirect_back fallback_location: root_path, notice: @string

    else
      # Type missing, nothing happens
      redirect_back fallback_location: root_path, notice: 'Nothing happened.'
    end
  end
	private 
		def recipe_params 
			params.require(:recipe).permit(:user_id, :search, :title, :description, portions_attributes:[:id, :amount, :_destroy]) 
		end

		# Confirms a logged-in user.
		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to search_recipe_path
			end
		end

		def user_has_recipes
			unless current_user.favourites.first
				redirect_to search_recipe_path
			end
		end

		# Confirms an admin user.
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end
end
