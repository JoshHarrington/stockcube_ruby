class CupboardsController < ApplicationController
	before_action :logged_in_user
	before_action :correct_user,   only: [:show, :edit, :update, :create]
	def index
		@cupboards = current_user.cupboards
		# redirect_to root_url and return unless @user.activated?
	end
	def show
		@cupboard = Cupboard.find(params[:id])
		@stocks = @cupboard.stocks
	end
	def new 
		@cupboard = cupboard.new 
  end
  def create
    @cupboard = Cupboard.new(cupboard_params)
    if @cupboard.save
      redirect_to '/cupboards'
    else
      render 'new'
    end
	end
	def edit
		@cupboard = Cupboard.find(params[:id])
		@stocks = @cupboard.stocks
	end
	def update
		@cupboard = Cupboard.find(params[:id])
		@stocks = @cupboard.stocks
      if @cupboard.update(cupboard_params)
        redirect_to @cupboard
      else
        render 'edit'
      end
  end
	private 
		def cupboard_params 
			params.require(:cupboard).permit(:location) 
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
			@user = @cupboard.user
			redirect_to(root_url) unless current_user?(@user)
		end
end
