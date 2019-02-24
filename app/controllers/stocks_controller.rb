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
		@stock = Stock.new(stock_params)

		@cupboards = current_user.cupboards.where(hidden: false, setup: false)
		@cupboard_found = @cupboards.map(&:id).include?(params[:stock][:cupboard_id].to_i)
		unless @cupboard_found
			@stock.update_attributes(
				cupboard_id: @cupboards.first
			)
		end


		# if params[:portion].has_key?(:ingredient_id) && params[:portion][:ingredient_id].present?
		# 	if params[:portion][:ingredient_id].to_i == 0
		# 		new_ingredient_from_portion = Ingredient.find_or_create_by(name: params[:portion][:ingredient_id], unit_id: (@portion_unit || 8))
		# 		selected_ingredient_id = new_ingredient_from_portion.id
		# 		new_stuff_added = true
		# 	else
		# 		selected_ingredient_id = params[:portion][:ingredient_id]
		# 	end
		# else
		# 	flash[:danger] = "Make sure you select an ingredient"
		# end
		if params.has_key?(:stock) && params[:stock].has_key?(:ingredient_id) && params[:stock][:ingredient_id].to_i == 0 && params[:stock][:ingredient_id].class == String
			if params[:stock].has_key?(:unit_id) && params[:stock][:unit_id].to_i != 0
				unit_id = params[:stock][:unit_id]
			else
				unit_id = 8
			end
			new_ingredient = Ingredient.find_or_create_by(name: params[:stock][:ingredient_id], unit_id: unit_id)
			@stock.update_attributes(
				ingredient_id: new_ingredient[:id]
			)
			Ingredient.reindex
		end


    if @stock.save
			redirect_to cupboards_path(anchor: @stock.cupboard_id)
			update_recipe_stock_matches(@stock[:ingredient_id])
			shopping_list_portions_update(current_user[:id])
			StockUser.create(
				stock_id: @stock.id,
				user_id: current_user[:id]
			)
		else
			unit_id = 8
			if params.has_key?(:stock) && params[:stock].has_key?(:unit_id) && params[:stock][:unit_id].to_i != 0
				unit_id = params[:stock][:unit_id]
			end
			ingredient_id = false
			if params.has_key?(:stock) && params[:stock].has_key?(:ingredient_id) && params[:stock][:ingredient_id].to_i != 0
				ingredient_id = params[:stock][:ingredient_id]
				### if ingredient name instead of id is given, create new ingredient
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

		if StockUser.where(stock_id: @stock[:id]).length == 0
			StockUser.create(
				stock_id: @stock.id,
				user_id: current_user[:id]
			)
		end

		if @stock.update(stock_params)
			redirect_to cupboards_path(anchor: @stock.cupboard_id)
			update_recipe_stock_matches(@stock[:ingredient_id])
			shopping_list_portions_update(current_user[:id])
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