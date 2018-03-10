class ShoppingListsController < ApplicationController
  def index
    @shopping_lists = current_user.shopping_lists
  end
  # def new
  # end

  # private
  #   # Confirms the correct user.
  ### need to update for show, check that this shopping list user is the current user
  #   def correct_user
  #     @user = User.find(params[:id])
  #     redirect_to(root_url) unless current_user?(@user)
  #   end
end
