class PortionsController < ApplicationController
	def show
		@portion = Portion.find(params[:id])
	end
	def edit
		@portion = Portion.find(params[:id])
	end
	def update
		@portion = Portion.find(params[:id])
		@meal = @portion.meal
      if @portion.update(portion_params)
        redirect_to meal_path(@meal)
      else
        render 'edit'
      end
	end
	private 
		def portion_params 
			params.require(:portion).permit(:amount) 
		end
end