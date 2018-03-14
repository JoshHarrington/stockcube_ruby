class ShoppingListsController < ApplicationController
  before_action :logged_in_user
	before_action :user_has_shopping_lists, only: :index

  def index
    @shopping_lists = current_user.shopping_lists
  end
	def new 
    @shopping_lists = ShoppingList.new
    @recipes = Recipe.all
    @user_id = current_user.id
  end
  def create
    # Rails.logger.debug params[:shopping_list][:recipes][:id]
    @recipe_ids = params[:shopping_list][:recipes][:id]
    @user = current_user
    @user_id = current_user.id
    @recipes = Recipe.all
    @recipe_pick = Recipe.find(@recipe_ids)
    @current_date = Date.today
    @new_shopping_list = ShoppingList.new(shopping_list_params)
    @user.shopping_lists << @new_shopping_list
    
    @new_shopping_list.recipes << @recipe_pick

    if @new_shopping_list.save
      redirect_to shopping_list_path(@new_shopping_list.id)
    else
      render 'new'
    end
  end
  
	def show
		@shopping_list = ShoppingList.find(params[:id])
		@recipes = @shopping_list.recipes
  end
  
  def edit
		@shopping_list = ShoppingList.find(params[:id])
		@recipes = @shopping_list.recipes
	end
	def update
    @shopping_list = ShoppingList.find(params[:id])
    @recipes = @shopping_list.recipes
    @existing_recipe_ids = []
    @recipes.each do |recipe|
      @existing_recipe_ids << recipe.id
    end

    @form_recipe_ids = params[:shopping_list][:recipes][:id]

    @recipes_to_remove = @existing_recipe_ids - @form_recipe_ids
    @recipes_to_add = @form_recipe_ids - @existing_recipe_ids

    @recipe_pick = Recipe.find(@recipes_to_add)
    @recipe_unpick = Recipe.find(@recipes_to_remove)

    @recipes.delete(@recipe_unpick)
    # @recipes.destroy(@recipes_to_remove)
    @recipes << @recipe_pick



    if @shopping_list.update(shopping_list_params)
      redirect_to shopping_list_path(@shopping_list)
    else
      render 'edit'
    end
	end

  # private
  ### need to update for show, new, update, check that this shopping list user is the current user
  #   def correct_user
  #     @user = User.find(params[:id])
  #     redirect_to(root_url) unless current_user?(@user)
  #   end

  private 
    def shopping_list_params
      params.require(:shopping_list).permit(:id, :date_created, recipes_attributes:[:id, :title, :description, :_destroy]) 
    end

    def user_has_shopping_lists
			unless current_user.shopping_lists.first
				redirect_to shopping_lists_new_path
			end
		end

    # Confirms a logged-in user.
		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to search_recipe_path
			end
		end
end
