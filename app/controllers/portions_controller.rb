class PortionsController < ApplicationController
	def show
		@portion = Portion.find(params[:id])
	end
	def edit
		@portion = Portion.find(params[:id])
	end
	def update
		@portion = Portion.find(params[:id])
		@recipe = @portion.recipe
      if @portion.update(portion_params)
        redirect_to recipe_path(@recipe)
      else
        render 'edit'
      end
	end
	private 
		def portion_params 
			params.require(:portion).permit(:amount) 
		end
end