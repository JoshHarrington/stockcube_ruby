class CupboardsController < ApplicationController
	before_action :authenticate_user!
	require 'set'
	include StockHelper
	include ShoppingListsHelper
	include CupboardHelper

	include PortionStockHelper

	before_action :correct_user,   only: [:show, :edit, :update]
	def index
		@cupboards = user_cupboards(current_user)
		@planner_recipes = current_user.planner_recipes.select{|pr| pr.date > Date.current - 1.days}
		@user_fav_stocks = current_user.user_fav_stocks.order('updated_at desc')
		@cupboard_users_hashids = Hashids.new(ENV['CUPBOARD_USER_ID_SALT'])
		@quick_add_hashids = Hashids.new(ENV['QUICK_ADD_STOCK_ID_SALT'])
		@delete_stock_hashids = Hashids.new(ENV['DELETE_STOCK_ID_SALT'])
		@cupboard_sharing_hashids = Hashids.new(ENV['CUPBOARD_SHARING_ID_SALT'])
		@cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
	end

	def demo
		@cupboards = user_cupboards(current_user)
		@planner_recipes = current_user.planner_recipes.select{|pr| pr.date > Date.current - 1.days}.reject{|pr| planner_stocks(pr).length == 0}
		@user_fav_stocks = current_user.user_fav_stocks.order('updated_at desc')
		@cupboard_users_hashids = Hashids.new(ENV['CUPBOARD_USER_ID_SALT'])
		@quick_add_hashids = Hashids.new(ENV['QUICK_ADD_STOCK_ID_SALT'])
		@delete_stock_hashids = Hashids.new(ENV['DELETE_STOCK_ID_SALT'])
		@cupboard_sharing_hashids = Hashids.new(ENV['CUPBOARD_SHARING_ID_SALT'])
		@cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
	end

	def show
		redirect_to cupboards_path
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
			@cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
			redirect_to stocks_new_path(:cupboard_id => @cupboard_id_hashids.encode(@cupboard.id))
    else
      render 'new'
    end
	end
	def share
		@cupboard_sharing_hashids = Hashids.new(ENV['CUPBOARD_SHARING_ID_SALT'])
		decrypted_cupboard_id = @cupboard_sharing_hashids.decode(params[:id])
		@cupboard = Cupboard.find(decrypted_cupboard_id.class == Array ? decrypted_cupboard_id.first : decrypted_cupboard_id)
		@cupboard_users_hashids = Hashids.new(ENV['CUPBOARD_USER_ID_SALT'])

		### This check to see if the current user should have access
		###  can go after rewriting :correct_user function
		if !@cupboard || !@cupboard.cupboard_users.map(&:user_id).include?(current_user.id)
			redirect_to cupboards_path
			flash[:info] = %Q[Looks like there's an issue with the cupboard you're trying to share, if in doubt contact <a href="mailto:support@getstockcubes.com">support@getstockcubes.com</a>]
		end

		@cupboard_name = @cupboard.location
		@all_other_cupboard_users = []
		if current_user.cupboards.length > 1
			@all_other_cupboard_users = User.where(id: current_user.cupboards.where.not(id: decrypted_cupboard_id).order(location: :asc).where(hidden: false, setup: false).map(&:users)[0].where.not(id: @cupboard.users.map(&:id)).uniq.map(&:id))
		end



		# if params.has_key?(:cupboard_id) && params[:cupboard_id].to_i != 0
		# 	@cupboards = current_user.cupboards.order(location: :asc).where(hidden: false, setup: false)
		# 	if @cupboards.map(&:id).include?(params[:cupboard_id].to_i)
		# 		@cupboard = Cupboard.find(params[:cupboard_id])
		# 		@cupboard_name = @cupboard.location
		# 		@current_cupboard_user_ids = []
		# 		if @cupboard.users.length > 0
		# 			@current_cupboard_user_ids = @cupboard.users.map(&:id)
		# 		end
		# 		@other_cupboard_user_ids = @cupboards.map{ |c| c.users.map(&:id).flatten.uniq.compact - @current_cupboard_user_ids }.flatten.uniq.compact
		# 		@other_cupboard_users = User.where(id: @other_cupboard_user_ids)
		# 	else
		# 		redirect_to cupboards_path
		# 		flash[:info] = %Q[Looks like there's an issue with the cupboard you're trying to share from, if in doubt contact <a href="mailto:support@getstockcubes.com">support@getstockcubes.com</a>]
		# 	end
		# else
		# 	redirect_to cupboards_path
		# 	flash[:info] = %Q[Looks like there's an issue with the cupboard you're trying to share from, if in doubt contact <a href="mailto:support@getstockcubes.com">support@getstockcubes.com</a>]
		# end
	end
	def share_request
		Rails.logger.debug "share request fired"
		Rails.logger.debug params

		emails_valid = true
		if params.has_key?(:cupboard_user_emails) && params[:cupboard_user_emails].to_s != ''
			cupboard_sharing_hashids = Hashids.new(ENV['CUPBOARD_SHARING_ID_SALT'])
			decrypted_cupboard_id = cupboard_sharing_hashids.decode(params[:id])
			cupboard = Cupboard.find(decrypted_cupboard_id.class == Array ? decrypted_cupboard_id.first : decrypted_cupboard_id)
			cupboard_user_emails_string = params[:cupboard_user_emails].to_s.downcase.gsub(/\s+/, '')
			cupboard_user_emails_array = (cupboard_user_emails_string.include?(',') ? cupboard_user_emails_string.split(',') : [].push(cupboard_user_emails_string))

			cupboard_user_emails_array.each do |email|
				if /^([a-zA-Z0-9_\-\.\+]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/.match?(email) == false
					emails_valid = false
					break
				end
			end

			if emails_valid == false
				flash[:warning] = %Q[Looks like there might be a typo in one of the emails you entered, please double-check!]
				redirect_to cupboard_share_path(params[:id], cupboard_user_emails: cupboard_user_emails_string)
			end

			if emails_valid == true
				cupboard_email_sharing_hashids = Hashids.new(ENV['CUPBOARD_EMAIL_SHARE_ID_SALT'])
				encoded_cupboard_id = cupboard_email_sharing_hashids.encode(decrypted_cupboard_id)
				cupboard_user_emails_array.each do |email|
					if User.where(email: email).exists?
						cupboard_sharing_user = User.where(email: email).last
						if not cupboard.users.include?(cupboard_sharing_user)
							cupboard.users << cupboard_sharing_user
							CupboardMailer.sharing_cupboard_request_existing_account(email, current_user, encoded_cupboard_id).deliver_now
							flash[:success] = "#{cupboard.location} shared!"
						else
							flash[:warning] = %Q[Looks like you're trying to share with someone who's already part of that cupboard, please check and resubmit]
							redirect_to cupboard_share_path(params[:id], cupboard_user_emails: cupboard_user_emails_string)
						end
					else
						## user does not get added to cupboard currently
						## need new table of sharing requests to accounts that don't yet exist that gets checked on setup of new users
						## if cupboard was shared with this user that gets created with an email in that table then cupboard should be optionally added

						unless CupboardInvitee.find_by(email: email)
							CupboardInvitee.create(
								email: email,
								cupboard_id: cupboard.id
							)
						end

						## could show as faded out cupboard on in users /cupboards view that they can add or delete
						## would need to show notification dot on cupboards to show activity.

						CupboardMailer.sharing_cupboard_request_new_account(email, current_user, encoded_cupboard_id).deliver_now
						flash[:success] = "#{cupboard.location} shared!"
					end
				end
				@cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
				redirect_to cupboards_path(anchor: @cupboard_id_hashids.encode(decrypted_cupboard_id))
			end
		end
	end

	def get_latest_planner_recipes

		unless current_user
			respond_to do |format|
				format.json { render json: {'get cupboard planner recipes': 'not allowed'}.as_json, status: 400}
				format.html { redirect_to planner_path }
			end and return
		end

		fetched_shopping_list_portions = shopping_list_portions(nil, current_user)

		respond_to do |format|
			format.json { render json: {
				plannerRecipes: processed_planner_recipes_with_date(current_user, true)
			}.as_json, status: 200}
		end
	end

	def accept_cupboard_invite
		if params.has_key?(:cupboard_id) && params[:cupboard_id].to_s != ''
			hashids = Hashids.new(ENV['CUPBOARD_EMAIL_SHARE_ID_SALT'])
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
			cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
			redirect_to cupboards_path(anchor: cupboard_id_hashids.encode(decrypted_cupboard_id.first))
		else
			flash[:danger] = %Q[Something went wrong! Email the team for help: <a href="mailto:team@getstockcubes.com?subject=Something%20went%20wrong%20when%20accepting%20a%20shared%20cupboard%20request" target="_blank">team@getstockcubes.com</a>]
			redirect_to root_path
		end
	end
	def location_update
		if params.has_key?(:cupboard_location) && params[:cupboard_location].to_s != '' && params.has_key?(:cupboard_id) && params[:cupboard_id].to_s != '' && Cupboard.find(params[:cupboard_id]).cupboard_users.where(owner: true).first.user == current_user
			@cupboard_id = params[:cupboard_id]
			@cupboard_title = params[:cupboard_location].strip
			@cupboard_to_edit = user_cupboards(current_user).select{|c| c.id == @cupboard_id.to_i}.first
			if @cupboard_to_edit.location != @cupboard_title
				@cupboard_to_edit.update_attributes(
					location: @cupboard_title
				)
				respond_to do |format|
					format.json { render json: {
						"status": "success",
						"location": @cupboard_title
					}.as_json, status: 200}
					format.html { redirect_to cupboards_path }
				end
			else
				respond_to do |format|
					format.json { render json: {
						"status": "no_change",
						"location": @cupboard_title
					}.as_json, status: 200}
					format.html { redirect_to cupboards_path }
				end
			end
		end
	end
	def delete
		if params.has_key?(:id) && params[:id].to_s != ''
			#  && current_user.cupboards.where(hidden: false, setup: false).length > 1 && Cupboard.find(params[:id]).cupboard_users.where(owner: true).first.user == current_user
			cupboards = user_cupboards(current_user)
			if cupboards.length > 1
				@cupboard_to_delete = cupboards.select{|c| c.id == params[:id].to_i}.first
				if @cupboard_to_delete.destroy
					respond_to do |format|
						format.json { render json: {"status": "success"}.as_json, status: 200}
						format.html { redirect_to cupboards_path }
					end
				else
					respond_to do |format|
						format.json { render json: {"status": "failure"}.as_json, status: 400}
						format.html { redirect_to cupboards_path }
					end
				end
			else
				respond_to do |format|
					format.json { render json: {"status": "not_allowed", "reason": "You only have one cupboard, so it's best not to delete it!"}.as_json, status: 405}
					format.html { redirect_to cupboards_path }
				end
			end
		end
	end

	def autosave_sorting
		return unless current_user && params.has_key?(:stock_id) && params.has_key?(:cupboard_id) && params[:stock_id].to_s != '' && params[:cupboard_id].to_s != ''
		@stock_to_edit = user_stock(current_user).select{|s|s.id == params[:stock_id].to_i}.first

		old_cupboard_id = @stock_to_edit.cupboard_id

		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		cupboard_id = cupboard_id_hashids.decode(params[:cupboard_id]).first

		if @stock_to_edit

			if old_cupboard_id != cupboard_id
				@stock_to_edit.update_attributes(
					cupboard_id: cupboard_id
				)
				respond_to do |format|
					format.json { render json: {"status": "success"}.as_json, status: 200}
					format.html { redirect_to cupboards_path }
				end
			else
				respond_to do |format|
					format.json { render json: {"status": "no_change"}.as_json, status: 200}
					format.html { redirect_to cupboards_path }
				end
			end
		else
			respond_to do |format|
				format.json { render json: {"status": "failure"}.as_json, status: 400}
				format.html { redirect_to cupboards_path }
			end
		end
	end

	def delete_quick_add_stock
		if params.has_key?(:quick_add_stock_id) && params[:quick_add_stock_id].to_s != ''
			quick_add_hashids = Hashids.new(ENV['QUICK_ADD_STOCK_ID_SALT'])
			decrypted_quick_add_id = quick_add_hashids.decode(params[:quick_add_stock_id])
			if current_user && current_user.user_fav_stocks.find(decrypted_quick_add_id).length
				current_user.user_fav_stocks.find(decrypted_quick_add_id.class == Array ? decrypted_quick_add_id.first : decrypted_quick_add_id).delete
			else
				Rails.logger.debug "No quick add stock found"
			end
		end
	end
	def delete_cupboard_user
		if params.has_key?(:user_id) && params[:user_id].to_s != ''
			user_hashids = Hashids.new(ENV['CUPBOARD_USER_ID_SALT'])
			decrypted_user_id = user_hashids.decode(params[:user_id])
			# Rails.logger.debug CupboardUser.find(decrypted_user_id).user.name
			# if current_user && current_user.user_fav_stocks.find(decrypted_user_id).length
			# 	current_user.user_fav_stocks.find(decrypted_user_id.class == Array ? decrypted_user_id.first : decrypted_user_id).delete
			# else
			# 	Rails.logger.debug "No quick add stock found"
			# end
		end
	end
	def edit
		@cupboard = Cupboard.find(params[:id])
		@stocks = @cupboard.stocks.order(use_by_date: :asc)
		unless @stocks.length > 0
			redirect_to cupboards_path
			flash[:warning] = %Q[Looks like there was a problem, <a href="mailto:support@getstockcubes.com">email us</a> if you need support]
		else
			@cupboard_ids = CupboardUser.where(user_id: current_user.id, accepted: true).map(&:cupboard_id)
			@all_cupboards = current_user.cupboards.where(id: @cupboard_ids).order(location: :asc).where(hidden: false, setup: false)
			@units = Unit.where.not(name: nil)
		end
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
  end
	private
		def cupboard_params
			params.require(:cupboard).permit(:location, :communal, stocks_attributes:[:id, :amount, :use_by_date, :_destroy])
		end

		# Confirms the correct user.
		def correct_user

			### rewrite this to always take encoded ids
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
