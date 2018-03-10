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
    @shopping_lists = ShoppingList.new(shopping_lists_params)
    if @shopping_lists.save
      redirect_to '/shopping_lists'
    else
      render 'new'
    end
	end

  # private
  ### need to update for show, new, update, check that this shopping list user is the current user
  #   def correct_user
  #     @user = User.find(params[:id])
  #     redirect_to(root_url) unless current_user?(@user)
  #   end

  private 
  def shopping_lists_params
    params.require(:shopping_list).permit(:user_id, :id, :date_created, recipes_attributes:[:id, :title, :description, :destroy]) 
  end
end
