class MealsController < ApplicationController
	def index
    @meals = Meal.all
	end
	def show
		@meal = Meal.find(params[:id])
		@portions = @meal.portions
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
	def edit
		@meal = Meal.find(params[:id])
		@portions = @meal.portions
	end
	def update
		@meal = Meal.find(params[:id])
		@portions = @meal.portions
      if @meal.update(meal_params)
        redirect_to @meal
      else
        render 'edit'
      end
  end
	private 
		def meal_params 
			params.require(:meal).permit(:title) 
		end
end
