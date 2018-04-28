class ShoppingListsController < ApplicationController
  require 'set'
  before_action :logged_in_user
	before_action :user_has_shopping_lists, only: :index

  def index
    @shopping_lists = current_user.shopping_lists.order('created_at DESC').paginate(:page => params[:page], :per_page => 3)
  end
	def new
    @shopping_lists = ShoppingList.new
    @recipes = Recipe.all
    @user_id = current_user.id
  end
  def create
    # Rails.logger.debug params[:shopping_list][:recipes][:id]
    @recipe_ids = params[:shopping_list][:recipes][:id]
    @user = current_user
    @user_id = current_user.id
    @recipes = Recipe.all
    @recipe_pick = Recipe.find(@recipe_ids)

    @current_date = Date.today
    @shopping_list = ShoppingList.new(shopping_list_params)

    @user.shopping_lists << @shopping_list
    @shopping_list.recipes << @recipe_pick

    shopping_list_portion_ids = []
    @shopping_list.recipes.each do |recipe|
      recipe.portions.each do |portion|
        shopping_list_portion_ids.push(portion.id)
      end
    end

    shopping_list_portion_ids.each do |portion_id|
      portion_obj = Portion.where(id: portion_id).first
      ingredient_obj = Ingredient.where(id: portion_obj.ingredient_id).first
      if ingredient_obj
        @shopping_list.ingredients << ingredient_obj
        shopping_list_portion_obj = ShoppingListPortion.where(ingredient_id: ingredient_obj.id, shopping_list_id: @shopping_list.id)
        portion_unit_obj = Unit.where(id: portion_obj.unit_number).first

        shopping_list_portion_obj.each do |shopping_list_portion|
          view_context.metric_transform_portion_update(shopping_list_portion, portion_unit_obj, portion_obj, ingredient_obj)
        end
      end
    end

    if @shopping_list.save
      redirect_to shopping_list_path(@shopping_list.id)
    else
      render 'new'
    end
  end

	def show
		@shopping_list = ShoppingList.find(params[:id])
		@recipes = @shopping_list.recipes
  end
	def show_ingredients
		@shopping_list = ShoppingList.find(params[:id])
    @recipes = @shopping_list.recipes
    @shopping_list_portions = @shopping_list.shopping_list_portions
    @ingredient_ids_set = Set[]
    @shopping_list_portions.each do |portion|
      @ingredient_ids_set.add(portion.ingredient_id)
    end

    @cupboard_ids = []
    current_user.cupboards.each do |cupboard|
      @cupboard_ids.push(cupboard.id)
    end

    @cupboards = Cupboard.find(@cupboard_ids)

    @cupboard_stock_ids = []
    @cupboards.each do |cupboard|
      @cupboard_stocks = Stock.where(cupboard_id: cupboard.id)
      @cupboard_stocks.each do |stock|
      # @cupboard.stocks.each do |stock|
        @cupboard_stock_ids.push(stock.id)
      end
    end

		# @cupboards.each do |cupboard|
		# 	cupboard.stocks do |stock|
		# 	end
		# end

		@cupboard_stock = Stock.find(@cupboard_stock_ids)
  end

  def edit
		@shopping_list = ShoppingList.find(params[:id])
		@recipes = @shopping_list.recipes
	end
	def update
    @shopping_list = ShoppingList.find(params[:id])
    @shopping_list_portions = @shopping_list.shopping_list_portions
    @recipes = @shopping_list.recipes
    @existing_recipe_ids = []
    @recipes.each do |recipe|
      @existing_recipe_ids << recipe.id
    end

    @form_recipe_ids = params[:shopping_list][:recipes][:id]

    @recipes_to_remove = @existing_recipe_ids - @form_recipe_ids
    @recipes_to_add = @form_recipe_ids - @existing_recipe_ids

    @recipe_unpick = Recipe.find(@recipes_to_remove)
    @recipe_pick = Recipe.find(@recipes_to_add)

    @recipes.delete(@recipe_unpick)
    @recipes << @recipe_pick

    @recipes_to_remove.each do |recipe_id|
      @shopping_list_portions_to_delete = @shopping_list_portions.where(recipe_number: recipe_id)
      @shopping_list_portions.delete(@shopping_list_portions_to_delete)
    end

    shopping_list_portion_ids = []
    @recipe_pick.each do |recipe|
      recipe.portions.each do |portion|
        shopping_list_portion_ids.push(portion.id)
      end
    end

    shopping_list_portion_ids.each do |portion_id|
      portion_obj = Portion.where(id: portion_id).first
      ingredient_obj = Ingredient.where(id: portion_obj.ingredient_id).first
      if ingredient_obj
        @shopping_list.ingredients << ingredient_obj
        shopping_list_portion_obj = ShoppingListPortion.where(ingredient_id: ingredient_obj.id, shopping_list_id: @shopping_list.id)
        portion_unit_obj = Unit.where(id: portion_obj.unit_number).first

        shopping_list_portion_obj.each do |shopping_list_portion|
          view_context.metric_transform_portion_update(shopping_list_portion, portion_unit_obj, portion_obj, ingredient_obj)
        end
      end
    end


    if @shopping_list.update(shopping_list_params)
      redirect_to shopping_list_path(@shopping_list)
    else
      render 'edit'
    end
	end

  # private
  ### need to update for show, new, update, check that this shopping list user is the current user
  #   def correct_user
  #     @user = User.find(params[:id])
  #     redirect_to(root_url) unless current_user?(@user)
  #   end

  private
    def shopping_list_params
      params.require(:shopping_list).permit(:id, :date_created, recipes_attributes:[:id, :title, :description, :_destroy])
    end

    def user_has_shopping_lists
			unless current_user.shopping_lists.first
				redirect_to shopping_lists_new_path
			end
		end

    # Confirms a logged-in user.
		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to search_recipe_path
			end
		end
end
