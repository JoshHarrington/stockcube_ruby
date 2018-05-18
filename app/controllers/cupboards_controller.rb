class CupboardsController < ApplicationController
	before_action :logged_in_user
	before_action :correct_user,   only: [:show, :edit, :update]
	def index
		@cupboards = current_user.cupboards.order(location: :asc)
		# redirect_to root_url and return unless @user.activated?
	end
	def show
		@cupboard = Cupboard.find(params[:id])
		@stocks = @cupboard.stocks.order(use_by_date: :asc)

	end
	def new
		@cupboard = Cupboard.new
  end
  def create
		@cupboard = Cupboard.new(cupboard_params)
		if current_user
			current_user.cupboards << @cupboard
		end
    if @cupboard.save
			redirect_to stocks_new_path(:cupboard_id => @cupboard.id)
    else
      render 'new'
    end
	end
	def edit
		@cupboard = Cupboard.find(params[:id])
		@stocks = @cupboard.stocks.order(use_by_date: :asc)
		@units = Unit.all
	end
	def update
		@cupboard = Cupboard.find(params[:id])
		@stocks = @cupboard.stocks.order(use_by_date: :asc)
		@units = Unit.all

		@stock_ids = []
		@stocks.each do |stock|
			@stock_ids.push(stock.id)
		end

		@delete_stock_check_ids = params[:cupboard][:stock][:id]
		@form_stock_ids = params[:cupboard][:stock_ids]
		@form_stock_amounts = params[:cupboard][:stock][:amount]
		@form_stock_ingredient_units = params[:cupboard][:stock][:ingredient][:unit]

		# Rails.logger.debug @delete_stock_check_ids
		if @delete_stock_check_ids
			@stock_unpick = Stock.find(@delete_stock_check_ids)
			@stocks.delete(@stock_unpick)
		end

		if @form_stock_amounts.length == @stocks.length
			@stocks.each_with_index do |stock, index|
				if not stock[:amount].to_f == @form_stock_amounts[index].to_f
					stock.update_attributes(
						:amount => @form_stock_amounts[index].to_f
					)
				end
				if @form_stock_ingredient_units.length == @stocks.length
					if not stock.ingredient.unit_id.to_f == @form_stock_ingredient_units[index].to_f
						stock.ingredient.update_attributes(
							:unit_id => @form_stock_ingredient_units[index].to_f
						)
					end
				end
			end
		end

		if @cupboard.update(cupboard_params)
			redirect_to @cupboard
		else
			render 'edit'
		end
  end
	private
		def cupboard_params
			params.require(:cupboard).permit(:location, stocks_attributes:[:id, :amount, :use_by_date, :_destroy])
		end

		# Confirms a logged-in user.
		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end

		# Confirms the correct user.
		def correct_user
			@cupboard = Cupboard.find(params[:id])
			@user = @cupboard.user
			redirect_to(root_url) unless current_user?(@user)
		end
end
