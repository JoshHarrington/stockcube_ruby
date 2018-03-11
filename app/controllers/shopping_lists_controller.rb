class ShoppingListsController < ApplicationController
  def index
    @shopping_lists = current_user.shopping_lists
  end
	def new 
    @shopping_lists = ShoppingList.new
    @recipes = Recipe.all
    @user_id = current_user.id
  end
  def create
    @user_id = current_user.id
    @recipes = Recipe.all
    @current_date = Date.today.to_s
    @recipe_pick = Recipe.all[0].id.to_s
    @shopping_lists = ShoppingList.new(shopping_lists_params)
    if @shopping_lists.save
      redirect_to '/shopping_lists'
    else
      render 'new'
    end
  end
  
	def show
		@shopping_list = ShoppingList.find(params[:id])
		@recipes = @shopping_list.recipes
	end

  # private
  ### need to update for show, new, update, check that this shopping list user is the current user
  #   def correct_user
  #     @user = User.find(params[:id])
  #     redirect_to(root_url) unless current_user?(@user)
  #   end

  private 
  def shopping_lists_params
    params.permit(:user_id, :id, :date_created, recipes_attributes:[:id, :title, :description, :destroy]) 
  end
end
