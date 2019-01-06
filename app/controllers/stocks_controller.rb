class StocksController < ApplicationController
	helper IntegerHelper
	include StockHelper
	include ShoppingListsHelper
	before_action :logged_in_user
	before_action :correct_user, only: [:edit]
	def index
		@stocks = Stock.all
	end
	def show
		@stock = Stock.find(params[:id])
	end
	def picks
		@tomatoe_id = Ingredient.where(name: "Tomatoes").first.id
		@egg_id = Ingredient.where(name: "Egg").first.id
		@bread_id = Ingredient.where(name: "Bread (White)").first.id  ## need to add (to production)
		@milk_id = Ingredient.where(name: "Milk").first.id
		@onion_id = Ingredient.where(name: "Onion").first.id
		@cheese_id = Ingredient.where(name: "Cheese (Cheddar)").first.id

		@each_unit_id = Unit.where(name: "Each").first.id
		@loaf_unit_id = Unit.where(name: "Loaf").first.id 	## need to add (to production)
		@pint_unit_id = Unit.where(name: "Pint").first.id
		@gram_unit_id = Unit.where(name: "Gram").first.id
	end

	def new
		@stock = Stock.new
		@cupboards = current_user.cupboards.where(hidden: false, setup: false).order(created_at: :desc)
		if @cupboards.length == 0
			new_cupboard = Cupboard.create(location: "Kitchen")
			CupboardUser.create(cupboard_id: new_cupboard.id, user_id: current_user.id, accepted: true, owner: true)
		end
		if params.has_key?(:cupboard_id) && params[:cupboard_id].present?
			@cupboard_found = @cupboards.map(&:id).include?(params[:cupboard_id].to_i)
		else
			@cupboard_found = false
		end
		@ingredients = Ingredient.all.sort_by{|i| i.name.downcase}
		if params.has_key?(:standard_use_by_limit) && params[:standard_use_by_limit]
			@use_by_limit = Date.current + params[:standard_use_by_limit].to_i.days
		else
			@use_by_limit = Date.current + 2.weeks
		end
		@unit_select = Unit.where.not(name: nil)

	end
	def create
		Rails.logger.debug stock_params
		@stock = Stock.new(stock_params)

		@cupboards = current_user.cupboards.where(hidden: false, setup: false)
		@cupboard_found = @cupboards.map(&:id).include?(params[:stock][:cupboard_id].to_i)
		unless @cupboard_found
			@stock.update_attributes(
				cupboard_id: @cupboards.first
			)
		end


    if @stock.save
			redirect_to cupboards_path(anchor: @stock.cupboard_id)
			recipe_stock_matches_update(current_user[:id], nil)
			shopping_list_portions_update(current_user[:id])
			flash[:info] = %Q[Recipe stock information updated!]
			StockUser.find_or_create_by(
				stock_id: @stock.id,
				user_id: current_user[:id]
			)
		else
			unit_id = 8
			if params.has_key?(:stock) && params[:stock].has_key?(:unit_id) && params[:stock][:unit_id].to_i != 0
				unit_id = params[:unit_id]
			end
			ingredient_id = false
			if params.has_key?(:stock) && params[:stock].has_key?(:ingredient_id) && params[:stock][:ingredient_id].to_i != 0
				ingredient_id = params[:stock][:ingredient_id]
			end
			cupboard_id = @cupboards.first
			if params.has_key?(:stock) && params[:stock].has_key?(:cupboard_id) && params[:stock][:cupboard_id].to_i != 0
				cupboard_id = params[:stock][:cupboard_id]
			end
			amount = false
			if params.has_key?(:stock) && params[:stock].has_key?(:amount) && params[:stock][:amount].to_i != 0
				amount = params[:stock][:amount]
			end

			flash[:danger] = %Q[Make sure you pick an ingredient, and set a stock amount]
			redirect_to stocks_new_path(cupboard_id: (cupboard_id || false), ingredient: (ingredient_id || false), stock_amount: (amount || false), unit: (unit_id || false))

    end
	end
	def edit
		@stock = Stock.find(params[:id])
		@current_cupboard = @stock.cupboard

		@cupboards = current_user.cupboards.where(hidden: false, setup: false).order(created_at: :desc)

		@ingredients = Ingredient.all.sort_by{|i| i.name.downcase}
		@current_ingredient = @stock.ingredient

		@unit_select = Unit.where.not(name: nil)

		@preselect_unit = @stock.unit_id
	end
	def update
		@stock = Stock.find(params[:id])

		StockUser.find_or_create_by(
			stock_id: @stock.id,
			user_id: current_user[:id]
		)

		if @stock.update(stock_params)
			redirect_to cupboards_path(anchor: @stock.cupboard_id)
			recipe_stock_matches_update(current_user[:id], nil)
			shopping_list_portions_update(current_user[:id])
			flash[:info] = %Q[Recipe stock information updated!]
		else
			flash[:danger] = %Q[Looks like there was a problem, make sure you pick an ingredient, and set a stock amount]
			redirect_to edit_stock_path(@stock), fallback: cupboards_path
		end
	end
	private
		def stock_params
			params.require(:stock).permit(:amount, :use_by_date, :unit_id, :ingredient_id, :cupboard_id)
		end

		# Confirms a logged-in user.
		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end

		def correct_user
			stock = Stock.find(params[:id])
			unless stock.cupboard.communal == false || stock.users.length == 0 || stock.users.map(&:id).include?(current_user[:id])
				redirect_to cupboards_path
			end
		end
end