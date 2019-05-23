class CupboardsController < ApplicationController
	require 'set'
	include StockHelper
	include ShoppingListsHelper
	before_action :logged_in_user, only: [:index, :show, :new, :create, :edit_all, :share, :share_request, :accept_cupboard_invite, :autosave, :autosave_sorting, :edit, :update]
	before_action :correct_user,   only: [:show, :edit, :update, :share]
	def index
		@cupboard_ids = CupboardUser.where(user_id: current_user.id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard.setup == true || cu.cupboard.hidden == true }.compact
		@cupboards = Cupboard.where(id: @cupboard_ids).order(created_at: :desc)
		@user_fav_stocks = current_user.user_fav_stocks.order('updated_at desc')
		@hashids = Hashids.new(ENV['CUPBOARD_USER_ID_SALT'])
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

		if @cupboard.save
			if current_user
				CupboardUser.create(
					cupboard_id: @cupboard.id,
					user_id: current_user.id,
					owner: true,
					accepted: true
				)
			end

			redirect_to stocks_new_path(:cupboard_id => @cupboard.id)
    else
      render 'new'
    end
	end
	def edit_all
		@cupboard_ids = CupboardUser.where(user_id: current_user.id, accepted: true).map(&:cupboard_id)
		@cupboards = current_user.cupboards.where(id: @cupboard_ids).order(location: :asc).where(hidden: false, setup: false)
	end
	def share
		if params.has_key?(:cupboard_id) && params[:cupboard_id].to_i != 0
			@cupboards = current_user.cupboards.order(location: :asc).where(hidden: false, setup: false)
			if @cupboards.map(&:id).include?(params[:cupboard_id].to_i)
				@cupboard = Cupboard.find(params[:cupboard_id])
				@cupboard_name = @cupboard.location
				@current_cupboard_user_ids = []
				if @cupboard.users.length > 0
					@current_cupboard_user_ids = @cupboard.users.map(&:id)
				end
				@other_cupboard_user_ids = @cupboards.map{ |c| c.users.map(&:id).flatten.uniq.compact - @current_cupboard_user_ids }.flatten.uniq.compact
				@other_cupboard_users = User.where(id: @other_cupboard_user_ids)
			else
				redirect_to cupboards_path
				flash[:info] = %Q[Looks like there's an issue with the cupboard you're trying to share from, if in doubt contact <a href="mailto:support@getstockcubes.com">support@getstockcubes.com</a>]
			end
		else
			redirect_to cupboards_path
			flash[:info] = %Q[Looks like there's an issue with the cupboard you're trying to share from, if in doubt contact <a href="mailto:support@getstockcubes.com">support@getstockcubes.com</a>]
		end
	end
	def share_request
		if params.has_key?(:cupboard_user_emails) && params[:cupboard_user_emails].to_s != '' && params.has_key?(:cupboard_id) && params[:cupboard_id].to_s != ''
			cupboard = Cupboard.find(params[:cupboard_id].to_i)
			cupboard_user_emails_string = params[:cupboard_user_emails].to_s.downcase
			cupboard_user_emails_string = cupboard_user_emails_string.gsub(/\s+/, "")
			if cupboard_user_emails_string.include? ","
				cupboard_user_emails_array = cupboard_user_emails_string.split(',')
			else
				cupboard_user_emails_array = []
				cupboard_user_emails_array.push(cupboard_user_emails_string)
			end
			if cupboard_user_emails_array.length > 0
				hashids = Hashids.new(ENV['CUPBOARD_ID_SALT'])
				encrypted_cupboard_id = hashids.encode(params[:cupboard_id])
				cupboard_user_emails_array.each do |email|
					if User.where(email: email).exists?
						cupboard_sharing_user = User.where(email: email).last
						if CupboardUser.where(cupboard_id: params[:cupboard_id], user_id: cupboard_sharing_user.id).length > 1
							## delete extra cupboard_users
							extra_cupboard_user_ids = CupboardUser.where(cupboard_id: params[:cupboard_id], user_id: cupboard_sharing_user.id).map(&:id)
							extra_cupboard_user_ids__less_first = extra_cupboard_user_ids[1..-1]
							CupboardUser.find(extra_cupboard_user_ids__less_first).delete_all
						elsif CupboardUser.where(cupboard_id: params[:cupboard_id], user_id: cupboard_sharing_user.id).length > 0
							flash[:info] = %Q[That cupboard has already been shared with that person! <br/><br/>They may need to accept it though]
						else
							cupboard.users << cupboard_sharing_user
							if email.include?("@") && email.include?(".")
								CupboardMailer.sharing_cupboard_request_existing_account(email, current_user, encrypted_cupboard_id).deliver_now
							end
							flash[:success] = "#{cupboard.location} shared!"
						end
					else
						if email.include?("@") && email.include?(".")
							CupboardMailer.sharing_cupboard_request_new_account(email, current_user, encrypted_cupboard_id).deliver_now
							flash[:success] = "#{cupboard.location} shared!"
						end
					end
				end
			end
		end

		if params.has_key?(:communal) && params.has_key?(:cupboard_id) && params[:cupboard_id].to_s != ''
			if current_user && (current_user.admin || (CupboardUser.where(user_id: current_user[:id], cupboard_id: params[:cupboard_id]).length > 0 && CupboardUser.where(user_id: current_user[:id], cupboard_id: params[:cupboard_id]).first.owner))
				cupboard = Cupboard.find(params[:cupboard_id])
				if params[:communal].to_s == 'false'
					cupboard.update_attributes(
						communal: false
					)
				elsif params[:communal].to_s == 'true'
					cupboard.update_attributes(
						communal: true
					)
				end
			end
		end

		redirect_to cupboards_path
	end

	def accept_cupboard_invite
		if params.has_key?(:cupboard_id) && params[:cupboard_id].to_s != ''
			hashids = Hashids.new(ENV['CUPBOARD_ID_SALT'])
			decrypted_cupboard_id = hashids.decode(params[:cupboard_id])
			if decrypted_cupboard_id.class.to_s == 'Array'
				decrypted_cupboard_id.each do |cupboard_id|
					CupboardUser.where(cupboard_id: cupboard_id, user_id: current_user.id).update_all(accepted: true)
				end
				if decrypted_cupboard_id.length > 1
					flash[:success] = "Multiple cupboards have been added!"
				else
					cupboard = Cupboard.where(id: decrypted_cupboard_id).first
					flash[:success] = "#{cupboard.location} has been added!"
				end
			else
				CupboardUser.where(cupboard_id: decrypted_cupboard_id, user_id: current_user.id).update_attributes(accepted: true)
				cupboard = Cupboard.where(id: decrypted_cupboard_id).first
				flash[:success] = "#{cupboard.location} has been added!"
			end
			redirect_to cupboards_path(anchor: decrypted_cupboard_id.first.to_s)
		else
			flash[:danger] = %Q[Something went wrong! Email the team for help: <a href="mailto:team@getstockcubes.com?subject=Something%20went%20wrong%20when%20accepting%20a%20shared%20cupboard%20request" target="_blank">team@getstockcubes.com</a>]
			redirect_to root_path
		end
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
			stock_ingredient_ids = @stock_to_delete.map(&:ingredient_id).uniq
			update_recipe_stock_matches(stock_ingredient_ids)
			shopping_list_portions_update(current_user[:id])
		end
		if params.has_key?(:cupboard_id_delete) && params[:cupboard_id_delete].to_s != '' && current_user.cupboards.where(hidden: false, setup: false).length > 1
			@cupboard_to_delete = Cupboard.find(params[:cupboard_id_delete].to_i)
			@cupboard_to_delete.update_attribute(
				:hidden, true
			)

			### this warning won't be shown at the right point in the flow so will just confuse users
			# elsif params.has_key?(:cupboard_id_delete) && params[:cupboard_id_delete].to_s != '' && current_user.cupboards.where(hidden: false, setup: false).length == 1
			# 	flash[:warning] = "Don't delete that cupboard! It's the last one you have :O"
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
		@cupboard_ids = CupboardUser.where(user_id: current_user.id, accepted: true).map(&:cupboard_id)
		@all_cupboards = current_user.cupboards.where(id: @cupboard_ids).order(location: :asc).where(hidden: false, setup: false)
		@stocks = @cupboard.stocks.order(use_by_date: :asc)
		@units = Unit.where.not(name: nil)
	end
	def update
		@cupboard = Cupboard.find(params[:id])
		@cupboard_ids = CupboardUser.where(user_id: current_user[:id], accepted: true).map(&:cupboard_id)
		@all_cupboards = current_user.cupboards.where(id: @cupboard_ids).order(location: :asc).where(hidden: false, setup: false)
		@stocks = @cupboard.stocks.order(use_by_date: :asc)
		@units = Unit.where.not(name: nil)

		cupboard_ingredient_ids = @cupboard.stocks.map(&:ingredient_id).uniq
		update_recipe_stock_matches(cupboard_ingredient_ids)

		if params.has_key?(:stock_items)
			params[:stock_items].to_unsafe_h.map do |stock_id, values|
				stock = Stock.find(stock_id)
				unless stock.amount == values[:amount]
					stock.update_attributes(
						amount: values[:amount]
					)
				end
				unless stock.unit_id == values[:unit_id]
					stock.update_attributes(
						unit_id: values[:unit_id]
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
		shopping_list_portions_update(current_user[:id])
  end
	private
		def cupboard_params
			params.require(:cupboard).permit(:location, :communal, stocks_attributes:[:id, :amount, :use_by_date, :_destroy])
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
			if params.has_key?(:cupboard_id) && params[:cupboard_id].to_s != '' && params[:id] != 'accept_cupboard_invite'
				@cupboard = Cupboard.find(params[:cupboard_id])
				@user_ids = @cupboard.users.map(&:id)
				redirect_to(cupboards_path) unless @user_ids.include?(current_user.id)
			elsif params.has_key?(:id) && params[:id].to_s != '' && params[:id] != 'accept_cupboard_invite'
				@cupboard = Cupboard.find(params[:id])
				@user_ids = @cupboard.users.map(&:id)
				redirect_to(cupboards_path) unless @user_ids.include?(current_user.id)
			end
		end
end
