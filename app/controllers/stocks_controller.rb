class StocksController < ApplicationController
	def index
		@stocks = Stock.all
	end
	def show
		@stock = Stock.find(params[:id])
	end
	def edit
		@stock = Stock.find(params[:id])
	end
	def update
		@stock = Stock.find(params[:id])
		@cupboard = @stock.cupboard
			if @stock.update(stock_params)
				redirect_to cupboard_path(@cupboard)
			else
				render 'edit'
			end
	end
	private 
		def stock_params 
			params.require(:stock).permit(:amount, :unit) 
		end
end