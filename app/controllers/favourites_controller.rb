class FavouritesController < ApplicationController
	def show
		@favourite = Favourite.find(params[:id])
	end
	# def edit
	# 	@favourite = Favourite.find(params[:id])
	# end
	# def update
	# 	@favourite = Favourite.find(params[:id])
	# 	@recipe = @favourite.recipe
  #     if @favourite.update(favourite_params)
  #       redirect_to recipe_path(@recipe)
  #     else
  #       render 'edit'
  #     end
	# end
	# private 
	# 	def favourite_params 
	# 		params.require(:favourite).permit(:amount) 
	# 	end
end