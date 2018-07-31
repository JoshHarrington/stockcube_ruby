class StocksController < ApplicationController
	before_action :logged_in_user
	# before_action :cupboard_id_param_check, only: [:create, :new, :edit, :update]
	def index
		@stocks = Stock.all
	end
	def show
		@stock = Stock.find(params[:id])
	end
	def new
		@stock = Stock.new
		@cupboards = current_user.cupboards.where(hidden: false, setup: false)
		@ingredients = Ingredient.all.order('name ASC')
		@two_weeks_from_now = Date.current + 2.weeks
		@unit_select = Unit.where.not(name: nil)

	end
	def create
		@stock = Stock.new(stock_params)
		@cupboards = current_user.cupboards.where(hidden: false, setup: false)
		@ingredients = Ingredient.all.order('name ASC')
		@two_weeks_from_now = Date.current + 2.weeks
		@unit_select = Unit.where.not(name: nil)

		if params.has_key?(:ingredient_id) && params[:ingredient_id].present?
			selected_ingredient_id = params[:ingredient_id]
		end

		if params.has_key?(:cupboard_id) && params[:cupboard_id].present?
			selected_cupboard_id = params[:cupboard_id]
		end

		@stock_amount = params[:amount]
		@stock_use_by_date = params[:stock][:use_by_date]
		@stock_unit = params[:unit_id]


		@stock.update_attributes(
			unit_id: @stock_unit,
			cupboard_id: (selected_cupboard_id || @cupboards.first),
			ingredient_id: selected_ingredient_id,
		)

		@cupboard_for_stock = @cupboards.where(id: @selected_cupboard_id).first

    if @stock.save
      redirect_to cupboards_path
    else
			render 'new'
			flash[:danger] = "Make sure you select an ingredient"
    end
	end
	def edit
		@stock = Stock.find(params[:id])
		@current_cupboard = @stock.cupboard


		@cupboards = []
		current_user.cupboards.where(hidden: false, setup: false).each do |cupboard|
			if @current_cupboard.users.map(&:id) == cupboard.users.map(&:id)
				@cupboards << cupboard
			end
		end

		if @cupboards.length != current_user.cupboards.where(hidden: false, setup: false).length
			@shared_cupboards = true
		end


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
		# @current_unit = @stock.unit
		# @current_ingredient_unit_number = @current_ingredient_unit.unit_number
		@stock_unit = @stock.unit


		### What's going on here?!
		### Can't update the cupboard id if more cupboard_users than 1?
		### need a system to figure if the people on the cupboard match?
		### or just notify the user before changing?
		unless params[:cupboard_id] == @current_cupboard.id || @current_cupboard.cupboard_users.length > 1
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

		if @stock.update(stock_params)
			redirect_to cupboards_path
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

		def cupboard_id_param_check
			unless params.has_key?(:cupboard_id)
				redirect_to cupboards_path
				flash[:danger] = "Add stock by editing a cupboards contents"
			end
		end
end