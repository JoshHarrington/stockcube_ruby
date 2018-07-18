class CupboardsController < ApplicationController
	before_action :logged_in_user
	before_action :correct_user,   only: [:show, :edit, :update]
	def index
		@cupboards = current_user.cupboards.order(location: :asc).where(hidden: false).where(setup: false)
		@out_of_date_exist = false
		@cupboards.each do |cupboard|
			cupboard.stocks.each do |stock|
				if (stock.use_by_date - Date.current).to_i <= -3
					@out_of_date_exist = true
					break if @out_of_date_exist == true
				end
				break if @out_of_date_exist == true
			end
			break if @out_of_date_exist == true
		end
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
			CupboardUser.create(
				cupboard_id: @cupboard.id,
				user_id: current_user.id,
				owner: true
			)
		end
    if @cupboard.save
			redirect_to stocks_new_path(:cupboard_id => @cupboard.id)
    else
      render 'new'
    end
	end
	def edit_all
		@cupboards = current_user.cupboards.order(location: :asc).where(hidden: false).where(setup: false)
	end
	def autosave
		if params.has_key?(:cupboard_location) && params[:cupboard_location].to_s != '' && params.has_key?(:cupboard_id) && params[:cupboard_id].to_s != ''
			@cupboard_id = params[:cupboard_id]
			@cupboard_title = params[:cupboard_location]
			@cupboard_to_edit = current_user.cupboards.find(@cupboard_id)
			@cupboard_to_edit.update_attributes(
				location: @cupboard_title
			)
		end
		if params.has_key?(:stock_id) && params[:stock_id].to_s != ''
			@stock_to_delete = Stock.find(params[:stock_id])
			@stock_to_delete.each do |stock|
				stock.update_attributes(
					hidden: true
				)
			end
		end
		if params.has_key?(:cupboard_id_delete) && params[:cupboard_id_delete].to_s != ''
			@cupboard_to_delete = Cupboard.find(params[:cupboard_id_delete].to_i)
			@cupboard_to_delete.update_attribute(
				:hidden, true
			)
		end
	end
	def autosave_sorting
		if current_user && params.has_key?(:stock_id) && params.has_key?(:cupboard_id) && params.has_key?(:old_cupboard_id) && params[:stock_id].to_s != '' && params[:cupboard_id].to_s != '' && params[:old_cupboard_id].to_s != ''
			@stock_to_edit = Stock.where(id: params[:stock_id]).first
			@stock_to_edit.update_attributes(
				cupboard_id: params[:cupboard_id]
			)
		end
	end
	def edit
		@cupboard = Cupboard.find(params[:id])
		@all_cupboards = current_user.cupboards.where(hidden: false).where(setup: false)
		@stocks = @cupboard.stocks.order(use_by_date: :asc)
		@units = Unit.all
	end
	def update
		@cupboard = Cupboard.find(params[:id])
		@all_cupboards = current_user.cupboards.where(hidden: false).where(setup: false)
		@stocks = @cupboard.stocks.order(use_by_date: :asc)
		@units = Unit.all


		if params.has_key?(:stock_items)
			params[:stock_items].to_unsafe_h.map do |stock_id, values|
				stock = Stock.find(stock_id)
				unless stock.amount == values[:amount]
					stock.update_attributes(
						amount: values[:amount]
					)
				end
				unless stock.unit_number == values[:unit_number]
					stock.update_attributes(
						unit_number: values[:unit_number]
					)
				end
				unless stock.use_by_date == values[:use_by_date]
					stock.update_attributes(
						use_by_date: values[:use_by_date]
					)
				end
				unless stock.cupboard_id == values[:cupboard]
					stock.update_attributes(
						cupboard_id: values[:cupboard]
					)
				end
				if values[:delete]
					Stock.find(values[:delete]).delete
				end
			end
		end


		if @cupboard.setup == true
			@cupboard.update_attributes(hidden: true)
		end

		redirect_to cupboards_path
		# redirect_to edit_cupboard_path(@cupboard.id)

		# @stock_ids = []
		# @stocks.each do |stock|
		# 	@stock_ids.push(stock.id)
		# end

		# @delete_stock_check_ids = params[:cupboard][:stock][:id]
		# @form_stock_ids = params[:cupboard][:stock_ids]
		# @form_stock_amounts = params[:cupboard][:stock][:amount]
		# @form_stock_ingredient_units = params[:cupboard][:stock][:ingredient][:unit]

		# # Rails.logger.debug @delete_stock_check_ids
		# if @delete_stock_check_ids
		# 	@stock_unpick = Stock.find(@delete_stock_check_ids)
		# 	@stocks.delete(@stock_unpick)
		# end

		# if @form_stock_amounts.length == @stocks.length
		# 	@stocks.each_with_index do |stock, index|
		# 		if not stock[:amount].to_f == @form_stock_amounts[index].to_f
		# 			stock.update_attributes(
		# 				:amount => @form_stock_amounts[index].to_f
		# 			)
		# 		end
		# 		if @form_stock_ingredient_units.length == @stocks.length
		# 			if not stock.ingredient.unit_id.to_f == @form_stock_ingredient_units[index].to_f
		# 				stock.ingredient.update_attributes(
		# 					:unit_id => @form_stock_ingredient_units[index].to_f
		# 				)
		# 			end
		# 		end
		# 	end
		# end

		# if @cupboard.update(cupboard_params)
		# 	redirect_to @cupboard
		# else
		# 	render 'edit'
		# end
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
			@user_ids = @cupboard.users.map(&:id)
			redirect_to(root_url) unless @user_ids.include?(current_user.id)
		end
end
