class ShoppingListsController < ApplicationController
  require 'set'
  before_action :logged_in_user
  before_action :user_has_shopping_lists, only: :index
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


    # @ingredient_ids_set = Set[]
    # @shopping_list_ingredients.each do |ingredient|
    #   @ingredient_ids_set.add(ingredient.id)
    # end
    @shopping_list_ingredient_ids = ShoppingListPortion.where(shopping_list_id: params[:id]).map(&:id)
    # @shopping_list_ingredient_ids = @shopping_list_ingredients.map(&:id)

    current_user_cupboard_ids = current_user.cupboards.map(&:id)

    # @cupboard_stock_ids = []
    # @cupboards.each do |cupboard|
    #   @cupboard_stocks.each do |stock|
    #     @cupboard_stock_ids.push(stock.id)
    #   end
    # end
    # @cupboard_stocks = Stock.where(cupboard_id: cupboard.id)
    # @cupboard_stock = Stock.find(@cupboard_stock_ids)


    not_in_stock_array = []
    not_enough_in_stock_array = []
    enough_in_stock_array = []
    loads_in_stock_array = []

    @shopping_list_ingredient_ids.each do |ingredient_id|
      if Stock.where(cupboard_id: current_user_cupboard_ids, ingredient_id: ingredient_id).length > 0
        ingredient_stock = Stock.where(cupboard_id: current_user_cupboard_ids, ingredient_id: ingredient_id)
        total_stock_amount = 0
        first_stock_unit_number = ingredient_stock.first.unit_number
        if ingredient_stock.length > 1
          ingredient_stock.each do |stock|
            stock_unit = Unit.where(unit_number: stock.unit_number)
            if stock_unit.metric_ratio
              stock_amount = metric_transform(stock, stock_unit)
              if stock.unit_number == first_stock_unit_number
                total_stock_amount += stock_amount
              end
            elsif stock.unit_number == first_stock_unit_number
              total_stock_amount += stock_amount
            else
              ## unsure what to do if unit_numbers don't match and metric_transform doesn't exist on stock
            end
          end
        else
          ingredient_stock = ingredient_stock.first
          stock_unit = Unit.where(unit_number: ingredient_stock.unit_number).first
          Rails.logger.debug metric_transform(ingredient_stock, stock_unit)
          if stock_unit.metric_ratio
            stock_amount = metric_transform(ingredient_stock, stock_unit)
            if stock.unit_number == first_stock_unit_number
              total_stock_amount += stock_amount
            end
          else
            total_stock_amount += stock_amount
          end
        end


        ingredient_portion = ShoppingListPortion.where(shopping_list_id: params[:id], ingredient_id: ingredient_id)
        total_portion_amount = 0
        first_portion_unit_number = ingredient_portion.first.unit_number
        if ingredient_portion.length > 1
          ingredient_portion.each do |portion|
            portion_unit = portion.ingredient.unit
            if portion_unit.metric_ratio
              portion_amount = metric_transform(portion, portion_unit)
              if portion.unit_number == first_portion_unit_number
                total_portion_amount += portion_amount
              end
            elsif portion.unit_number == first_portion_unit_number
              total_portion_amount += portion_amount
            else
              ## unsure what to do if unit_numbers don't match and metric_transform doesn't exist on portion
            end
          end
        else
          portion_unit = Unit.where(unit_number: ingredient_portion.unit_number)
          if portion_unit.metric_ratio
            portion_amount = metric_transform(ingredient_portion, portion_unit)
            if ingredient_portion.unit_number == first_portion_unit_number
              total_portion_amount += portion_amount
            end
          else
            total_portion_amount += portion_amount
          end
        end


        if ingredient_stock.length > 1
          stock_unit_type = Unit.where(unit_number: ingredient_stock.first.unit_number).unit_type
        else
          stock_unit_type = Unit.where(unit_number: ingredient_stock.unit_number).unit_type
        end

        if ingredient_portion.length > 1
          portion_unit_type = Unit.where(unit_number: ingredient_portion.first.unit_number).unit_type
        else
          portion_unit_type = Unit.where(unit_number: ingredient_portion.unit_number).unit_type
        end

        if stock_unit_type == portion_unit_type
          if total_portion_amount > total_stock_amount
            not_enough_in_stock_array.push(ingredient_id)
          else
            if total_stock_amount > total_portion_amount*2
              loads_in_stock_array.push(ingredient_id)
            else
              enough_in_stock_array.push(ingredient_id)
            end
          end
        else
          ## something wrong here, the stock and portion aren't of the same unit_type
        end

      end
      not_in_stock_array.push(ingredient_id)
    end

    # portion_amount = ShoppingListPortion.where(ingredient_id: @shopping_list_ingredients, shopping_list_id: params[:id]).sum(&:amount).to_i






    #   @ingredient_ids_set.each do |ingredient_id|
    #     ingredient_name = Ingredient.where(id: ingredient_id).first.name
    #     portion_obj_first = ShoppingListPortion.where(ingredient_id: ingredient_id, shopping_list_id: params[:id]).first
    #     portion_unit_number = portion_obj_first.unit_number
    #     portion_unit = Unit.where(unit_number: portion_unit_number).first
    #     unit = Unit.where(id: portion_unit_number).first
    #     portion_amount = ShoppingListPortion.where(ingredient_id: ingredient_id, shopping_list_id: params[:id]).sum(&:amount).to_i



    #     current_user_stocks = Stock.where(cupboard_id: current_user_cupboard_ids)

    #     cupboard_stock_amount = 0

    #     current_user_stocks.each do |stock|
    #       if stock.ingredient_id == ingredient_id
    #         cupboard_stock_amount = Stock.where(id: stock.id).sum(&:amount).to_i
    #       end
    #     end

    #     if cupboard_stock_amount != 0
    #       stock_obj = Stock.where(ingredient_id: ingredient_id).first
    #       stock_unit_obj = stock_obj.ingredient.unit
    #       if stock_unit_obj.metric_ratio
    #         metric_transform(stock_obj, stock_unit_obj)
    #       end

    #       proportion_in_cupboard = cupboard_stock_amount / portion_amount

    #       if proportion_in_cupboard < 1
    #         cupboard_situation = cupboard_stock_amount.to_s + " " + portion_unit.name + " already in cupboard"
    #         some_in_stock = true
    #       elsif proportion_in_cupboard < 2
    #         cupboard_situation = "More than enough in cupboard already"
    #         loads_in_stock = true
    #       else
    #         cupboard_situation = "More than enough in cupboard, about " + proportion_in_cupboard.to_floor.to_s + " times more than you need"
    #         loads_in_stock = true
    #       end
    #     else
    #       cupboard_situation = "Not in cupboards"
    #       not_in_stock = true
    #     end

    #     # if unit.name == "Each" || unit.name == "Side"
    #     if unit.unit_number == 5 || unit.unit_number == 44
    #       portion_desc = portion_amount.to_s + ' ' + ingredient_name.pluralize(portion_amount.to_i)
    #       portion_description = portion_desc
    #     else
    #       if unit.short_name
    #         if unit.name.downcase.include?("milliliter")
    #           portion_desc = portion_amount.to_s + unit.short_name.downcase.to_s + ' ' + ingredient_name.to_s
    #           portion_description = portion_desc
    #         else
    #           portion_desc = portion_amount.to_s + ' ' + unit.name.to_s + ' ' + ingredient_name.to_s
    #           portion_description = portion_desc
    #         end
    #       else
    #         unit.name = unit.name.pluralize(portion_amount.to_i)
    #         portion_desc = portion_amount.to_s + ' ' + unit.name.to_s + ' ' + ingredient_name.to_s
    #         portion_description = portion_desc
    #       end
    #     end

    #     if loads_in_stock == true
    #       loads_in_stock_hash[portion_description] = cupboard_situation
    #     end
    #     if some_in_stock == true
    #       some_in_stock_hash[portion_description] = cupboard_situation
    #     end
    #     if not_in_stock == true
    #       not_in_stock_hash[portion_description] = cupboard_situation
    #     end

    #   end










    # @cupboard_ids = []
    # current_user.cupboards.each do |cupboard|
    #   @cupboard_ids.push(cupboard.id)
    # end

    # @cupboards = Cupboard.find(@cupboard_ids)


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
    def correct_user
      @shopping_list = ShoppingList.find(params[:id])
      unless current_user == @shopping_list.user
        store_location
        flash[:danger] = "That's not your shopping list!"
        redirect_to shopping_lists_path
      end
    end
end
