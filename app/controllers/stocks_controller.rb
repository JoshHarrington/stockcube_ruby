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

	def new_no_id
		@cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		@cupboards = current_user.cupboards.where(hidden: false, setup: false).order(created_at: :desc)
		if @cupboards.length == 0
			new_cupboard = Cupboard.create(location: "Kitchen")
			CupboardUser.create(cupboard_id: new_cupboard.id, user_id: current_user.id, accepted: true, owner: true)
			redirect_to stocks_new_path(:cupboard_id => @cupboard_id_hashids.encode(new_cupboard[:id]))
			flash[:warning] = %Q[Looks like you didn't have a cupboard to add stock to so we've created one for you]
		else
			redirect_to stocks_new_path(:cupboard_id => @cupboard_id_hashids.encode(@cupboards.first.id))
		end
	end

	def new
		@cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		@stock = Stock.new
		@cupboards = current_user.cupboards.where(hidden: false, setup: false).order(created_at: :desc)
		if @cupboards.length == 0
			new_cupboard = Cupboard.create(location: "Kitchen")
			CupboardUser.create(cupboard_id: new_cupboard.id, user_id: current_user.id, accepted: true, owner: true)
			redirect_to stocks_new_path(:cupboard_id => @cupboard_id_hashids.encode(new_cupboard[:id]))
			flash[:warning] = %Q[Looks like you didn't have a cupboard to add stock to so we've created one for you]
		end
		@ingredients = Ingredient.all.reject{|i| i.name == ''}.sort_by{|i| i.name.downcase}
		if params.has_key?(:standard_use_by_limit) && params[:standard_use_by_limit]
			@use_by_limit = Date.current + params[:standard_use_by_limit].to_i.days
		else
			@use_by_limit = Date.current + 2.weeks
		end
		@unit_select = Unit.where.not(name: nil)

	end
	def create
		@stock = Stock.new(stock_params)
		Rails.logger.debug params

		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])

		@cupboards = current_user.cupboards.where(hidden: false, setup: false)

		if (params.has_key?(:id) && @cupboards.map(&:id).include?(cupboard_id_hashids.decode(params[:id]).first))
			@stock.update_attributes(
				cupboard_id: cupboard_id_hashids.decode(params[:id]).first
			)
		elsif @cupboards.map(&:id).include?(cupboard_id_hashids.decode(params[:stock][:cupboard_id]).first)
			@stock.update_attributes(
				cupboard_id: cupboard_id_hashids.decode(params[:stock][:cupboard_id]).first
			)
		else
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
			redirect_to cupboards_path(anchor: cupboard_id_hashids.encode(@stock.cupboard_id))
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
			cupboard_id = @cupboards.first.id
			if params.has_key?(:cupboard_id) && @cupboards.map(&:id).include?(cupboard_id_hashids.decode(params[:cupboard_id]).first)
				cupboard_id = cupboard_id_hashids.decode(params[:id])
			elsif params.has_key?(:stock) && params[:stock].has_key?(:cupboard_id) && params[:stock][:cupboard_id].to_i != 0
				cupboard_id = params[:stock][:cupboard_id]
			end
			amount = false
			if params.has_key?(:stock) && params[:stock].has_key?(:amount) && params[:stock][:amount].to_i != 0
				amount = params[:stock][:amount]
			end

			flash[:danger] = %Q[Make sure you pick an ingredient, and set a stock amount]
			encoded_cupboard_id = cupboard_id_hashids.encode(cupboard_id)
			redirect_to stocks_new_path(cupboard_id: encoded_cupboard_id, ingredient: (ingredient_id || false),  unit: (unit_id || false), stock_amount: (amount || false))

    end
	end
	def edit
		@stock = Stock.find(params[:id])
		@current_cupboard = @stock.cupboard

		if @stock.planner_recipe_id == nil
			@cupboards = current_user.cupboard_users.where(accepted: true).select{|cu| cu.cupboard.setup == false && cu.cupboard.hidden == false }.map{|cu| cu.cupboard }.sort_by{|c| c.updated_at}
		else
			@cupboards = []
		end

		@ingredients = Ingredient.all.sort_by{|i| i.name.downcase}
		@current_ingredient = @stock.ingredient

		@unit_select = Unit.where.not(name: nil)

		@preselect_unit = @stock.unit_id

		@delete_stock_hashids = Hashids.new(ENV['DELETE_STOCK_ID_SALT'])
	end

	def add_shopping_list_portion
		return unless params.has_key?(:shopping_list_portion_id) && current_user && params.has_key?(:portion_type) && params.has_key?(:date)
		planner_portion_id_hash = Hashids.new(ENV['PLANNER_PORTIONS_SALT'])
		if params[:portion_type] == 'combi_portion'
			combi_portion = current_user.combi_planner_shopping_list_portions.find(planner_portion_id_hash.decode(params[:shopping_list_portion_id])).first
		elsif params[:portion_type] == 'individual_portion'
			individual_portion = current_user.planner_shopping_list_portions.find(planner_portion_id_hash.decode(params[:shopping_list_portion_id])).first
		end

		if combi_portion.present?
			combi_portion.planner_shopping_list_portions.each do |portion|
				add_individual_portion_as_stock(portion)
				portion.destroy
			end
			combi_portion.destroy
		end
		if individual_portion.present?
			add_individual_portion_as_stock(individual_portion)
			individual_portion.destroy
		end

	end

	def delete_stock
		if params.has_key?(:stock_id) && params[:stock_id].to_s != ''
			stock_hashids = Hashids.new(ENV['DELETE_STOCK_ID_SALT'])
			decrypted_stock_id = stock_hashids.decode(params[:stock_id])
			if current_user && current_user.stocks.find(decrypted_stock_id).length
				current_user.stocks.find(decrypted_stock_id.class == Array ? decrypted_stock_id.first : decrypted_stock_id).delete
			else
				Rails.logger.debug "No stock found with that id for that user"
				flash[:warning] = %Q[Something went wrong! Please email <a href="mailto:help@getstockcubes.com">mailto:help@getstockcubes.com</a> for support."]
			end
		end
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
			cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
			redirect_to cupboards_path(anchor: cupboard_id_hashids.encode(@stock.cupboard_id))
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