class ShoppingListsController < ApplicationController
  require 'set'
  include ActionView::Helpers::NumberHelper
  include ShoppingListsHelper
  before_action :logged_in_user
  before_action :user_has_shopping_lists, only: [:index, :show, :show_ingredients, :show_current, :show_ingredients_current, :shop, :shopping_list_to_cupboard, :edit]
  before_action :correct_user, only: [:show, :edit]

  def index
    @shopping_lists = current_user.shopping_lists.order('created_at DESC').paginate(:page => params[:page], :per_page => 12)
  end
	def new
    @shopping_lists = ShoppingList.new
    @recipes = Recipe.all
    @user_id = current_user.id
  end
  def create
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

  def show_current
    @shopping_list = current_user.shopping_lists.last
    @shopping_list_portions = @shopping_list.shopping_list_portions
    @recipes = @shopping_list.recipes
  end

  def show_ingredients
    @shopping_list = ShoppingList.find(params[:id])
    @shopping_list_portions = @shopping_list.shopping_list_portions
  end

  def show_ingredients_current
    @shopping_list = current_user.shopping_lists.last
    @shopping_list_portions = @shopping_list.shopping_list_portions
  end

  def shop
    @shopping_list = current_user.shopping_lists.last
    @shopping_list_portions = @shopping_list.shopping_list_portions
  end

  def shopping_list_to_cupboard
    @import_cupboard = Cupboard.create(location: "Import Cupboard (Hidden)", setup: true, user_id: current_user.id)

    stocks = params[:shopping_list_item].to_unsafe_h.map do |ingredient_id, x|
       unit_number = x.keys.first
       amount = x.values.first
       Stock.create(
        unit_number: unit_number,
        amount: amount,
        ingredient_id: ingredient_id,
        cupboard_id: @import_cupboard.id,
        use_by_date: 2.weeks.from_now
      )
    end

    current_user.shopping_lists.last.update_attributes(
      archived: true
    )

    redirect_to edit_cupboard_path(@import_cupboard.id)

  end

  def edit
		@shopping_list = ShoppingList.find(params[:id])
		@recipes = @shopping_list.recipes
	end
	def update
    @shopping_list = ShoppingList.find(params[:id])
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

    shopping_list_portions_set(@shopping_list)

    if @shopping_list.update(shopping_list_params)
      redirect_to shopping_list_path(@shopping_list)
    else
      render 'edit'
    end
  end

  def autosave
    if params.has_key?(:shopping_list_id) && params[:shopping_list_id].to_s != '' && params.has_key?(:recipe_id) && params[:recipe_id].to_s != ''
      shopping_list = ShoppingList.find(params[:shopping_list_id])
      recipes_to_delete = Recipe.find(params[:recipe_id])
      recipes_to_delete.each do |recipe|
        shopping_list.recipes.delete(recipe)
      end
      shopping_list_portions_set(shopping_list)
		end
  end


  def delete
    @shopping_list = ShoppingList.find(params[:id])
    if current_user == @shopping_list.user
        @shopping_list.shopping_list_portions.destroy_all
        @shopping_list.shopping_list_recipes.destroy_all
        @shopping_list.destroy
        if current_user.shopping_lists.first
          redirect_to shopping_lists_path
        else
          redirect_to recipes_path
        end
    end
  end


  private
    def shopping_list_params
      params.require(:shopping_list).permit(:id, :date_created, :archived, recipes_attributes:[:id, :title, :description, :_destroy], shopping_list_portion_attributes:[:id, :unit_number, :_destroy], unit_attributes:[:id, :unit_type, :_destroy], shopping_list_item:[ingredient_id:[unit_number:[:amount]]])
    end

    def user_has_shopping_lists
			unless current_user.shopping_lists.last.archived == false && current_user.shopping_lists.last.recipes.length != 0
				redirect_to root_url
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
    def correct_user
      @shopping_list = ShoppingList.find(params[:id])
      unless current_user == @shopping_list.user
        store_location
        flash[:danger] = "That's not your shopping list!"
        redirect_to shopping_lists_path
      end
    end
end
