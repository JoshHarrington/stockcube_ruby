class CupboardController < ApplicationController
	def index
    @cupboards = Cupboard.all
	end
	def show
		@cupboard = Cupboard.find(params[:id])
    @ingredients = @cupboard.ingredients
	end
end
