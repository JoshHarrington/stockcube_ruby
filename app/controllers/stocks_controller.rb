class StocksController < ApplicationController
	helper IntegerHelper
	include StockHelper
	include ShoppingListsHelper
	before_action :logged_in_user
	before_action :cupboard_id_provided, only: [:new]
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
		user_cupboards = current_user.cupboards.where(hidden: false, setup: false)
		if user_cupboards.length == 0
			new_cupboard = Cupboard.create(location: "Fridge (Default cupboard)")
			CupboardUser.create(cupboard_id: new_cupboard.id, user_id: current_user.id, accepted: true, owner: true)
		end
		current_cupboard_user_ids = CupboardUser.where(cupboard_id: params[:cupboard_id]).map(&:user_id)
		@cupboards = current_user.cupboards.map{ |c| c if c.cupboard_users.map(&:user_id) == current_cupboard_user_ids && c.hidden == false && c.setup == false }.compact
		@ingredients = Ingredient.all.order('name ASC')
		if params.has_key?(:standard_use_by_limit) && params[:standard_use_by_limit]
			@use_by_limit = Date.current + params[:standard_use_by_limit].to_i.days
		else
			@use_by_limit = Date.current + 2.weeks
		end
		@unit_select = Unit.where.not(name: nil)

	end
	def create
		@stock = Stock.new(stock_params)
		if params.has_key?(:cupboard_id) && params[:cupboard_id].present?
			selected_cupboard_id = params[:cupboard_id]
		end
		current_cupboard_user_ids = CupboardUser.where(cupboard_id: selected_cupboard_id).map(&:user_id)
		@cupboards = current_user.cupboards.map{ |c| c if c.cupboard_users.map(&:user_id) == current_cupboard_user_ids && c.hidden == false && c.setup == false }.compact

		@ingredients = Ingredient.all.order('name ASC')
		@two_weeks_from_now = Date.current + 2.weeks
		@unit_select = Unit.where.not(name: nil)
		new_stuff_added = false


		if params.has_key?(:unit_id) && params[:unit_id].present?
			if params[:unit_id].to_i == 0
				new_unit_from_stock = Unit.find_or_create_by(name: params[:unit_id])
				@stock_unit = new_unit_from_stock.id
				new_stuff_added = true
			else
				@stock_unit = params[:unit_id]
			end
		else
			flash[:danger] = "Make sure you select or add a unit"
		end

		if params.has_key?(:ingredient_id) && params[:ingredient_id].present?
			if params[:ingredient_id].to_i == 0
				new_ingredient_from_stock = Ingredient.find_or_create_by(name: params[:ingredient_id], unit_id: (@stock_unit || 8))
				selected_ingredient_id = new_ingredient_from_stock.id
				new_stuff_added = true
			else
				selected_ingredient_id = params[:ingredient_id]
			end
		else
			flash[:danger] = "Make sure you select an ingredient"
		end

		@stock_amount = params[:amount]
		@stock_use_by_date = params[:stock][:use_by_date]


		@stock.update_attributes(
			unit_id: @stock_unit,
			cupboard_id: (selected_cupboard_id || @cupboards.first),
			ingredient_id: selected_ingredient_id,
		)

		StockUser.create(
			stock_id: @stock.id,
			user_id: current_user[:id]
		)

    if @stock.save
			redirect_to cupboards_path
			recipe_stock_matches_update(current_user[:id], nil)
			shopping_list_portions_update(current_user[:id])
			flash[:info] = %Q[Recipe stock information updated!]
		else
			if params.has_key?(:unit_id) && params[:unit_id].to_i != 0 && params.has_key?(:ingredient_id) && params[:ingredient_id].to_i != 0
				redirect_to stocks_new_path(unit: params[:unit_id], ingredient: params[:ingredient_id])
			elsif params.has_key?(:unit_id) && params[:unit_id].present? && params[:unit_id].to_i != 0
				redirect_to stocks_new_path(unit: params[:unit_id])
			elsif params.has_key?(:ingredient_id) && params[:ingredient_id].present? && params[:ingredient_id].to_i != 0
				redirect_to stocks_new_path(ingredient: params[:ingredient_id])
			else
				redirect_to stocks_new_path
			end
			# render 'new'
    end
	end
	def edit
		@stock = Stock.find(params[:id])
		@current_cupboard = @stock.cupboard

		current_cupboard_user_ids = CupboardUser.where(cupboard_id: @current_cupboard.id).map(&:user_id)
		@cupboards = current_user.cupboards.map{ |c| c if c.cupboard_users.map(&:user_id) == current_cupboard_user_ids && c.hidden == false && c.setup == false }.compact

		@ingredients = Ingredient.all.order('name ASC')
		@current_ingredient = @stock.ingredient

		@units_select = Unit.where.not(name: nil)

		@preselect_unit = @stock.unit_id
	end
	def update
		@stock = Stock.find(params[:id])
		@current_cupboard = @stock.cupboard

		@cupboards = []
		current_user.cupboards.where(hidden: false, setup: false).each do |cupboard|
			if @current_cupboard.id != cupboard.id && (@current_cupboard.users.map(&:id) == cupboard.users.map(&:id))
				@cupboards << cupboard
			end
		end

		@ingredients = Ingredient.all.order('name ASC')
		@current_ingredient = @stock.ingredient

		unless params[:cupboard_id] == @current_cupboard.id
			@stock.update_attributes(
				cupboard_id: params[:cupboard_id]
			)
		end

		@units_select = Unit.where.not(name: nil)

		@preselect_unit = @stock.unit_id

		unless params[:unit_id] == @stock.unit_id
			@stock.update_attributes(
				unit_id: params[:unit_id]
			)
		end

		unless params[:amount] == @stock.amount
			@stock.update_attributes(
				amount: params[:amount]
			)
		end

		StockUser.find_or_create_by(
			stock_id: @stock.id,
			user_id: current_user[:id]
		)

		if @stock.update(stock_params)
			redirect_to cupboards_path
			recipe_stock_matches_update(current_user[:id], nil)
			shopping_list_portions_update(current_user[:id])
			flash[:info] = %Q[Recipe stock information updated!]
		else
			render 'edit'
		end
	end
	private
		def stock_params
			params.require(:stock).permit(:amount, :use_by_date, :unit_id, ingredient_attributes: [:id, :name, :image, :unit, :_destroy])
		end

		# Confirms a logged-in user.
		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end

		def cupboard_id_provided
			if params.has_key?(:cupboard_id)
				cupboard_user_length = CupboardUser.where(user_id: current_user[:id], cupboard_id: params[:cupboard_id], accepted: true).length
				if cupboard_user_length == 0
					redirect_to cupboards_path
					flash[:danger] = "Stock has to be added to your cupboards, not someone else's!"
				end
			else
				redirect_to cupboards_path
				flash[:danger] = "Stock has to be added to a cupboard, else it would disappear into the ether!"
			end
		end

		def correct_user
			stock = Stock.find(params[:id])
			unless stock.cupboard.communal == false || stock.users.length == 0 || stock.users.map(&:id).include?(current_user[:id])
				redirect_to cupboards_path
			end
		end
end