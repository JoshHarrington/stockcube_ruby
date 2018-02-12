class MealsController < ApplicationController
	def index
    @meals = Meal.all
	end
	def show
		@meal = Meal.find(params[:id])
    @ingredients = @meal.ingredients
	end
	def new 
		@meal = Meal.new 

  end
  def create
    @meal = Meal.new(meal_params)
    if @meal.save
      redirect_to '/meals'
    else
      render 'new'
    end
	end
	private 
		def meal_params 
			params.require(:meal).permit(:title) 
			# params.require(:portion).permit(:amount, :unit)
		end
end
