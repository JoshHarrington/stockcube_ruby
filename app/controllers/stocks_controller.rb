class StocksController < ApplicationController
	def index
		@stocks = Stock.all
	end
	def show
		@stock = Stock.find(params[:id])
		@meals = @ingredient.meals
		@cupboards = @ingredient.cupboards
	end
end
