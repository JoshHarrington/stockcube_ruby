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
    # Rails.logger.debug "hello world"
    Rails.logger.debug params[:shopping_list][:recipes][:id]
    @recipe_ids = params[:shopping_list][:recipes][:id]
    @user = current_user
    @user_id = current_user.id
    @recipes = Recipe.all
    @recipe_pick = Recipe.find(@recipe_ids)
    @current_date = Date.today
    @new_shopping_list = ShoppingList.new(shopping_lists_params)
    @new_shopping_list.update_attributes(
      :date_created => @current_date
    )
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

  # private
  ### need to update for show, new, update, check that this shopping list user is the current user
  #   def correct_user
  #     @user = User.find(params[:id])
  #     redirect_to(root_url) unless current_user?(@user)
  #   end

  private 
    def shopping_lists_params
      params.require(:shopping_list).permit(:id, :date_created, recipes_attributes:[:id, :title, :description, :_destroy]) 
    end
end
