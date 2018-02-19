class CupboardsController < ApplicationController
	def index
    @cupboards = Cupboard.all
	end
	def show
		@cupboard = Cupboard.find(params[:id])
		@stocks = @cupboard.stocks
    @ingredients = @cupboard.ingredients
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
end
