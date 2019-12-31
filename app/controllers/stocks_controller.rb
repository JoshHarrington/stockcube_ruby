class StocksController < ApplicationController

	helper IntegerHelper
	include StockHelper
	include ServingHelper
	include ShoppingListsHelper
	before_action :authenticate_user!, except: [:add_shopping_list_portion, :remove_shopping_list_portion]
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
		@cupboards = user_cupboards(current_user.id)
		if @cupboards.length == 0
			create_cupboard_if_none
			redirect_to stocks_new_path(:cupboard_id => @cupboard_id_hashids.encode(new_cupboard[:id]))
			flash[:warning] = %Q[Looks like you didn't have a cupboard to add stock to so we've created one for you]
		else
			redirect_to stocks_new_path(:cupboard_id => @cupboard_id_hashids.encode(@cupboards.first.id))
		end
	end

	def new
		@stock = Stock.new

		@top_ingredients = ordered_typical_ingredients().map{|i| Ingredient.where('lower(name) = ?', i[:name].downcase).first}.compact.select{|new_i| new_i.default_ingredient_sizes.length > 0}
		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		if current_user.cupboards.length == 0
			@cupboard_id = create_cupboard_if_none(true)
		else
			@cupboards = user_cupboards(current_user.id)
			if params.has_key?(:cupboard_id) && @cupboards.map(&:id).include?(cupboard_id_hashids.decode(params[:cupboard_id]).first)
				@cupboard_id = params[:cupboard_id]
			else
				@cupboard_id = cupboard_id_hashids.encode(@cupboards.first.id)
			end
		end

	end

	def custom_new
		@cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		@stock = Stock.new
		@cupboards = user_cupboards(current_user.id)
		if @cupboards.length == 0
			create_cupboard_if_none
			redirect_to stocks_custom_new_path(:cupboard_id => @cupboard_id_hashids.encode(new_cupboard[:id]))
			flash[:warning] = %Q[Looks like you didn't have a cupboard to add stock to so we've created one for you]
		end
		@ingredients = Ingredient.all.reject{|i| i.name == ''}.sort_by{|i| i.name.downcase}
		if params.has_key?(:standard_use_by_limit) && params[:standard_use_by_limit]
			@use_by_limit = Date.current + params[:standard_use_by_limit].to_i.days
		else
			@use_by_limit = Date.current + 2.weeks
		end
	end

	def create

		create_stock(current_user.id, stock_params)

		@cupboards = user_cupboards(current_user.id)

		validated_cupboard_ids = validate_cupboard_id(current_user.id, params[:cupboard_id])

    if @stock.save
			redirect_to stocks_new_path(cupboard_id: validated_cupboard_ids[:encoded])
		else
			flash[:danger] = %Q[Something went wrong! Sorry about that]
			redirect_to stocks_new_path(cupboard_id: validated_cupboard_ids[:encoded])
    end
	end

	def create_custom
		@stock = create_stock(current_user.id, stock_params)

		@cupboards = user_cupboards(current_user.id)

		validated_cupboard_ids = validate_cupboard_id(current_user.id, params[:cupboard_id])

    if @stock != nil
			redirect_to cupboards_path(anchor: validated_cupboard_ids[:encoded])
		else
			flash[:danger] = %Q[Make sure you pick an ingredient, and set a stock amount]
			redirect_to stocks_custom_new_path(cupboard_id: validated_cupboard_ids[:encoded])
    end

	end

	def edit
		@stock = Stock.find(params[:id])
		@current_cupboard = @stock.cupboard

		if @stock.planner_recipe_id == nil
			@cupboards = user_cupboards(current_user.id)
		else
			@cupboards = []
		end

		@ingredients = Ingredient.all.sort_by{|i| i.name.downcase}
		@current_ingredient = @stock.ingredient

		@preselect_unit = @stock.unit_id

		@delete_stock_hashids = Hashids.new(ENV['DELETE_STOCK_ID_SALT'])
	end

	def add_shopping_list_portion
		toggle_stock_on_portion_check(params, 'add_portion')
	end

	def remove_shopping_list_portion
		toggle_stock_on_portion_check(params, 'remove_portion')
	end

	def add_shopping_list
		return unless current_user
		current_user.planner_shopping_list.update_attributes(
			ready: false
		)
		shopping_list = current_user.planner_shopping_list
		portions = current_user.planner_recipes.select{|pr| pr.date > Date.current - 6.hours && pr.date < Date.current + 7.day}.map{|pr| pr.planner_shopping_list_portions.reject{|p| p.combi_planner_shopping_list_portion_id != nil}.reject{|p| p.ingredient.name.downcase == 'water'}}.flatten
		combi_portions = shopping_list.combi_planner_shopping_list_portions.select{|c|c.date > Date.current - 6.hours && c.date < Date.current + 7.day}
		if combi_portions.length > 0
			combi_portions.each do |combi_portion|
				add_individual_portion_as_stock(combi_portion.planner_shopping_list_portions)
				combi_portion.destroy
			end
		end

		if portions.length > 0
			add_individual_portion_as_stock(portions)
		end

		all_portions = combi_portions + portions
		all_portion_ids = all_portions.map(&:ingredient_id)

		update_recipe_stock_matches_core(all_portion_ids, current_user.id)

		current_user.planner_shopping_list.update_attributes(
			ready: true
		)
	end

	def delete_stock
		if params.has_key?(:id) && params[:id].to_s != ''
			delete_stock_hashids = Hashids.new(ENV['DELETE_STOCK_ID_SALT'])
			cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
			decrypted_stock_id = delete_stock_hashids.decode(params[:id])
			return unless current_user && current_user.stocks.find(decrypted_stock_id).length > 0
			stock = current_user.stocks.find(decrypted_stock_id).first
			cupboard_id = stock.cupboard_id
			stock.destroy
			if !params.has_key?(:type) || (params.has_key?(:type) && params[:type].to_s != 'post')
				redirect_to cupboards_path(anchor: cupboard_id_hashids.encode(cupboard_id))
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
		else
			flash[:danger] = %Q[Looks like there was a problem, make sure you pick an ingredient, and set a stock amount]
			redirect_to edit_stock_path(@stock), fallback: cupboards_path
		end
	end
	private
		def stock_params
			params.require(:stock).permit(:amount, :use_by_date, :unit_id, :ingredient_id, :cupboard_id)
		end


		def correct_user
			stock = Stock.find(params[:id])
			unless stock.cupboard.communal == false || stock.users.length == 0 || stock.users.map(&:id).include?(current_user[:id])
				redirect_to cupboards_path
			end
		end

		def create_cupboard_if_none(output = nil)
			@cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
			new_cupboard = Cupboard.create(location: "Your first cupboard")
			CupboardUser.create(cupboard_id: new_cupboard.id, user_id: current_user.id, accepted: true, owner: true)
			if output != nil
				return @cupboard_id_hashids.encode(new_cupboard.id)
			end
		end
end