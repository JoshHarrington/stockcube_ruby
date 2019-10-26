class UserFavStocksController < ApplicationController
	before_action :authenticate_user!
	def new
		@user_fav_stock = UserFavStock.new
		@user = current_user
		@ingredients = Ingredient.all.order('name ASC')
	end
	def create
		@user_fav_stock = UserFavStock.new(user_fav_stock_params)
		@user_fav_stock.user_id = current_user.id if current_user
		@user = current_user
		@ingredients = Ingredient.all.order('name ASC')
		if @user_fav_stock.save
			flash[:success] = 'New "Quick add stock" created!'
			redirect_to cupboards_path(anchor: 'quick_add_stock')
    else
      render 'new'
		end
	end
	def edit
		@user_fav_stock = UserFavStock.find(params[:id])
		@user = current_user
		@ingredients = Ingredient.all.order('name ASC')
	end
	def update
		@user_fav_stock = UserFavStock.find(params[:id])
		@user_fav_stock.user_id = current_user.id if current_user
		@user = current_user
		@ingredients = Ingredient.all.order('name ASC')
    if @user_fav_stock.update_attributes(user_fav_stock_params)
      flash[:success] = '"Quick add stock" updated!'
      redirect_to cupboards_path
    else
      render 'edit'
    end
	end
	def destroy
    UserFavStock.find(params[:id]).destroy
    flash[:success] = "Stock template deleted"
    redirect_to cupboards_path
  end

  private

    def user_fav_stock_params
			params.require(:user_fav_stock).permit(:ingredient_id, :stock_amount, :unit_id, :user_id, :standard_use_by_limit)
    end
end