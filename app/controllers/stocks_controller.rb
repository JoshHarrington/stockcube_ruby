class StocksController < ApplicationController

	helper IntegerHelper
	include StockHelper
	include ServingHelper
	include ShoppingListsHelper
	include CupboardHelper
	include PlannerShoppingListHelper
	include UnitsHelper
	include IngredientsHelper

	include PortionStockHelper

	before_action :authenticate_user!, except: [:toggle_shopping_list_portion]

	def index
		redirect_to cupboards_path
	end
	def show
		redirect_to cupboards_path
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
		@gram_unit_id = Unit.where(name: "gram").first.id
	end


	def create_from_post
		if !user_signed_in?
			respond_to do |format|
				format.json {
					render json: {
						'adding new cupboard stock': 'not authorised'
					}.as_json, status: 401
				}
				format.html {
					redirect_back fallback_location: root_path,
					notice: 'You are not currently authorised to complete that action'
				}
			end and return
		end


		if !params.has_key?(:cupboardId) ||
			!params.has_key?(:ingredient) ||
			!params.has_key?(:amount) ||
			!params.has_key?(:unitId) ||
			!params.has_key?(:useByDate)

			respond_to do |format|
				format.json {
					render json: {
						'adding new cupboard stock': 'bad request'
					}.as_json, status: 400
				}
				format.html {
					redirect_back fallback_location: root_path,
					notice: 'There was an issue when trying to complete that action'
				}
			end and return
		end

		ingredient = nil
		if params[:ingredient].is_number?
			if Ingredient.exists?(params[:ingredient])
				ingredient = Ingredient.find(params[:ingredient])
			else
				respond_to do |format|
					format.json {
						render json: {
							'adding new cupboard stock': 'bad request'
						}.as_json, status: 400
					}
					format.html {
						redirect_back fallback_location: root_path,
						notice: 'There was an issue when trying to complete that action'
					}
				end and return
			end
		else
			ingredient = Ingredient.create(name: params[:ingredient])
			UserMailer.admin_ingredient_add_notification(current_user, ingredient).deliver_now
			Ingredient.reindex
		end

		@cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])

		new_stock = Stock.new(
			cupboard_id: @cupboard_id_hashids.decode(params[:cupboardId]).first,
			ingredient_id: ingredient.id,
			unit_id: params[:unitId],
			amount: params[:amount],
			use_by_date: params[:useByDate].to_date
		)

		if new_stock.save
			StockUser.create(user_id: current_user.id, stock_id: new_stock.id)
			validated_cupboard_ids = validate_cupboard_id(current_user.id, params[:cupboardId])

			respond_to do |format|
				format.json {
					render json: {
						'adding new cupboard stock': 'successful'
					}.as_json, status: 200
				}
				format.html {
					redirect_to cupboards_path(anchor: validated_cupboard_ids[:encoded]),
					notice: 'Stock added to your cupboard'
				}
			end and return
		else
			respond_to do |format|
				format.json {
					render json: {
						'adding new cupboard stock': 'bad request'
					}.as_json, status: 400
				}
				format.html {
					redirect_back fallback_location: root_path,
					notice: 'There was an issue when trying to complete that action'
				}
			end and return
		end

	end


	def new_no_id
		@cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		@cupboards = user_cupboards(current_user)
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
			@cupboards = user_cupboards(current_user)
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
		@cupboards = user_cupboards(current_user)
		@units = unit_list()

		if !params.has_key?(:cupboard_id) || !(Cupboard.exists?(@cupboard_id_hashids.decode(params[:cupboard_id]).first)) || !user_can_access_cupboard(user: current_user, cupboard_id: @cupboard_id_hashids.decode(params[:cupboard_id]).first)
			redirect_back fallback_location: cupboards_path, notice: "There was something wrong with that link, please try to add stock again"
		end and return

		@ingredients = ingredient_list()
		current_cupboard = user_cupboards(current_user).find(@cupboard_id_hashids.decode(params[:cupboard_id]).first).first

		@cupboard_name = current_cupboard.location
		@cupboard_id = @cupboard_id_hashids.encode(current_cupboard.id)

		if @cupboards.length == 0
			create_cupboard_if_none
			redirect_to stocks_custom_new_path(:cupboard_id => @cupboard_id_hashids.encode(new_cupboard[:id]))
			flash[:warning] = %Q[Looks like you didn't have a cupboard to add stock to so we've created one for you]
		end and return

		if params.has_key?(:standard_use_by_limit) && params[:standard_use_by_limit]
			@use_by_limit = Date.current + params[:standard_use_by_limit].to_i.days
		else
			@use_by_limit = Date.current + 2.weeks
		end
	end

	def create

		create_stock(current_user.id, stock_params)

		@cupboards = user_cupboards(current_user)

		validated_cupboard_ids = validate_cupboard_id(current_user.id, params[:cupboard_id])

		if @stock.save
			StockUser.create(
				stock_id: @stock.id,
				user_id: current_user.id
			)
			combine_existing_similar_stock(current_user)
			redirect_to stocks_new_path(cupboard_id: validated_cupboard_ids[:encoded])
		else
			flash[:danger] = %Q[Something went wrong! Sorry about that]
			redirect_to stocks_new_path(cupboard_id: validated_cupboard_ids[:encoded])
    end
	end

	def create_custom
		@stock = create_stock(current_user.id, stock_params)

		@cupboards = user_cupboards(current_user)

		validated_cupboard_ids = validate_cupboard_id(current_user.id, params[:cupboard_id])

		if @stock != nil
			StockUser.create(
				stock_id: @stock.id,
				user_id: current_user.id
			)
			combine_existing_similar_stock(current_user)
			redirect_to cupboards_path(anchor: validated_cupboard_ids[:encoded])
		else
			flash[:danger] = %Q[Make sure you pick an ingredient, and set a stock amount]
			redirect_to stocks_custom_new_path(cupboard_id: validated_cupboard_ids[:encoded])
    end

	end

	def edit
		@cupboards = user_cupboards(current_user)
		@units = unit_list()
		@stock = current_user.stocks.where(id: params[:id]).first
		if @stock == nil
			redirect_back fallback_location: cupboards_path, notice: "There was something wrong with that link, please refresh and try again"
			return
		end

		@current_cupboard = @stock.cupboard
		@is_planner_stock = !!@stock.planner_recipe_id

		@cupboard_name = @stock.cupboard.location

		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		@cupboard_id = cupboard_id_hashids.encode(@stock.cupboard_id)


		### to stop from people moving stock to other cupboard
		### while it is required by a planner recipe we don't show cupboards
		# if @stock.planner_recipe_id == nil
		# 	@cupboards = user_cupboards(current_user)
		# else
		# 	@cupboards = []
		# end

		@ingredients = ingredient_list()
		@current_ingredient = @stock.ingredient

		preselect_unit = @stock.unit

		@preselect_unit_id = preselect_unit.id
		preselect_unit_type = preselect_unit.unit_type

		Rails.logger.debug "preselect_unit"
		Rails.logger.debug preselect_unit
		Rails.logger.debug preselect_unit_type

		@unit_list = unit_list_for_select(preselect_unit_type)


		@delete_stock_hashids = Hashids.new(ENV['DELETE_STOCK_ID_SALT'])
	end

	def update_from_post
		if !user_signed_in?
			respond_to do |format|
				format.json {
					render json: {
						'adding new cupboard stock': 'not authorised'
					}.as_json, status: 401
				}
				format.html {
					redirect_back fallback_location: root_path,
					notice: 'You are not currently authorised to complete that action'
				}
			end and return
		end


		if !params.has_key?(:cupboardId) ||
			!params.has_key?(:stockId) ||
			!params.has_key?(:amount) ||
			!params.has_key?(:unitId) ||
			!params.has_key?(:useByDate)

			respond_to do |format|
				format.json {
					render json: {
						'adding new cupboard stock': 'bad request'
					}.as_json, status: 400
				}
				format.html {
					redirect_back fallback_location: root_path,
					notice: 'There was an issue when trying to complete that action'
				}
			end and return
		end

		if not current_user.stocks.exists?(params[:stockId])
			respond_to do |format|
				format.json {
					render json: {
						'editing cupboard stock': 'not found'
					}.as_json, status: 404
				}
				format.html {
					redirect_back fallback_location: root_path,
					notice: 'There was an issue when trying to complete that action'
				}
			end and return
		end

		stock = current_user.stocks.find(params[:stockId])

		if stock.update(amount: params[:amount], unit_id: params[:unitId], use_by_date: params[:useByDate].to_date)
			StockUser.find_or_create_by(user_id: current_user.id, stock_id: stock.id)
			validated_cupboard_ids = validate_cupboard_id(current_user.id, params[:cupboardId])

			respond_to do |format|
				format.json {
					render json: {
						'editing cupboard stock': 'successful'
					}.as_json, status: 200
				}
				format.html {
					redirect_to cupboards_path(anchor: validated_cupboard_ids[:encoded]),
					notice: 'Stock added to your cupboard'
				}
			end and return
		else
			respond_to do |format|
				format.json {
					render json: {
						'editing cupboard stock': 'bad request'
					}.as_json, status: 400
				}
				format.html {
					redirect_back fallback_location: root_path,
					notice: 'There was an issue when trying to complete that action'
				}
			end and return
		end

	end

	def toggle_shopping_list_portion

		unless params.has_key?(:shopping_list_portion_id) && params.has_key?(:portion_type)
			respond_to do |format|
				format.json { render json: {'message': 'Bad portion params'}.as_json, status: 400}
				format.html { redirect_to planner_path }
			end and return
		end

		planner_portion_id = planner_portion_id_hash.decode(params[:shopping_list_portion_id]).first

		if params[:portion_type] == "individual_portion"
			planner_portion = PlannerShoppingListPortion.find(planner_portion_id)
		elsif params[:portion_type] == "combi_portion"
			planner_portion = CombiPlannerShoppingListPortion.find(planner_portion_id)
		else
			respond_to do |format|
				format.json { render json: {'message': 'Portion type not found'}.as_json, status: 404}
				format.html { redirect_to planner_path }
			end and return
		end

		### serving_description returns nil after combi portion stock has been cleaned out
		### so currently description is generated before updates to combi portion or stock
		planner_portion_description = serving_description(planner_portion)


		planner_shopping_list = planner_portion.planner_shopping_list

		if planner_shopping_list.ready == false
			Rails.logger.debug "planner_shopping_list.ready == false"

			respond_to do |format|
				format.json { render json: {message: 'Server busy'}.as_json, status: 408}
				format.html { redirect_to planner_path }
			end and return
		end

		planner_shopping_list.update_attributes(ready: false)


		checked_state = !planner_portion.checked

		planner_portion.update_attributes(
			checked: checked_state
		)

		if params[:portion_type] == "combi_portion"
			planner_portion.planner_shopping_list_portions.update_all(
				checked: checked_state
			)
		elsif checked_state == false && planner_portion.combi_planner_shopping_list_portion_id != nil
			planner_portion.combi_planner_shopping_list_portion.update_attributes(
				checked: false
			)
		end

		if checked_state == true
			add_stock_after_portion_checked(planner_portion, params[:portion_type])
		else
			remove_stock_after_portion_unchecked(planner_portion, params[:portion_type])
		end


		# deleting and recreating the combi portions is needed because of the stock deletes happening
		delete_old_combi_planner_portions_and_create_new(planner_portion.planner_shopping_list.id)

		fetched_shopping_list_portions = shopping_list_portions(planner_portion.planner_shopping_list)
		processed_fetched_shopping_list_portions = processed_shopping_list_portions(fetched_shopping_list_portions)


		planner_shopping_list.update_attributes(ready: true)

		respond_to do |format|
			format.json { render json: {
				shoppingListPortions: processed_fetched_shopping_list_portions,
				portionDescription: planner_portion_description,
				checkedPortionCount: fetched_shopping_list_portions.count{|p|p[:checked]},
				totalPortionCount: fetched_shopping_list_portions.count
			}.as_json, status: 200}
			format.html { redirect_to planner_path }
		end

	end

	def delete_stock
		return unless params.has_key?(:id) && params[:id].to_s != '' && user_signed_in?

		delete_stock_hashids = Hashids.new(ENV['DELETE_STOCK_ID_SALT'])
		decrypted_stock_id = delete_stock_hashids.decode(params[:id]).first
		stock = current_user.stocks.find(decrypted_stock_id)

		if stock == nil
			respond_to do |format|
				format.json { render json: {"status": "no_stock_found"}.as_json, status: 404}
				format.html {redirect_to cupboards_path}
			end and return
		end

		cupboard_id = stock.cupboard_id

		stock_without_planner_portion = stock.planner_shopping_list_portion_id == nil ? true : false
		non_post_request = !params.has_key?(:type) || (params.has_key?(:type) && params[:type].to_s != 'post')

		send_to_specific_cupboard = stock_without_planner_portion && non_post_request

		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		encoded_cupboard_id = cupboard_id_hashids.encode(cupboard_id)

		if stock.destroy
			respond_to do |format|
				format.json { render json: {status: "success"}.as_json, status: 200}
				format.html { redirect_to(cupboards_path(anchor: send_to_specific_cupboard ? encoded_cupboard_id : "")) }
			end
		else
			respond_to do |format|
				format.json { render json: {"status": "fails"}.as_json, status: 400}
				format.html { redirect_to(cupboards_path(anchor: send_to_specific_cupboard ? encoded_cupboard_id : "")) }
			end
		end

	end


	def delete_stock_post
		Rails.logger.debug "delete_stock_post params[:encoded_id]"
		Rails.logger.debug params[:encoded_id]

		return unless params.has_key?(:encoded_id) && params[:encoded_id].to_s != '' && user_signed_in?

		delete_stock_hashids = Hashids.new(ENV['DELETE_STOCK_ID_SALT'])
		decrypted_stock_id = delete_stock_hashids.decode(params[:encoded_id]).first
		stock = current_user.stocks.find(decrypted_stock_id)

		if stock == nil
			respond_to do |format|
				format.json { render json: {"status": "no_stock_found"}.as_json, status: 404}
				format.html {redirect_to cupboards_path}
			end and return
		end

		stock_description = serving_description(stock)

		cupboard_id = stock.cupboard_id

		stock_without_planner_portion = stock.planner_shopping_list_portion_id == nil ? true : false
		non_post_request = !params.has_key?(:type) || (params.has_key?(:type) && params[:type].to_s != 'post')

		send_to_specific_cupboard = stock_without_planner_portion && non_post_request

		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		encoded_cupboard_id = cupboard_id_hashids.encode(cupboard_id)

		if stock.destroy
			respond_to do |format|
				format.json { render json: {
					status: "success",
					cupboardContents: processed_cupboard_contents(current_user),
					stockDescription: stock_description
				}.as_json, status: 200}
				format.html { redirect_to(cupboards_path(anchor: send_to_specific_cupboard ? encoded_cupboard_id : "")) }
			end
		else
			respond_to do |format|
				format.json { render json: {"status": "fails"}.as_json, status: 400}
				format.html { redirect_to(cupboards_path(anchor: send_to_specific_cupboard ? encoded_cupboard_id : "")) }
			end
		end

	end

	def update
		@stock = Stock.find(params[:id])

		StockUser.find_or_create_by(
			stock_id: @stock.id,
			user_id: current_user[:id]
		)

		if @stock.update(stock_params)
			cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
			if @stock.planner_shopping_list_portion_id != nil
				cupboard_redirect_path = cupboards_path
				matching_portions = current_user.planner_shopping_list_portions
					.select{|p|p.ingredient_id == @stock.ingredient_id}

				if matching_portions.length > 0
					matching_portions.each do |portion|
						find_matching_stock_for_portion(portion)
					end
				end

				if percentage_of_portion_in_stock(@stock) > 95
					@stock.planner_shopping_list_portion.update_attributes(
						checked: true
					)
				else
					@stock.planner_shopping_list_portion.update_attributes(
						checked: false
					)
				end

			else
				cupboard_redirect_path = cupboards_path(anchor: cupboard_id_hashids.encode(@stock.cupboard_id))
			end
			delete_old_combi_planner_portions_and_create_new(current_user.planner_shopping_list.id)
			redirect_to cupboard_redirect_path
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
			stock = current_user.stocks.where(id: params[:id]).first
			if stock == nil
				redirect_to cupboards_path
				return
			end
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