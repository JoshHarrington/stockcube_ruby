require 'will_paginate/array'
class RecipesController < ApplicationController
	include ActionView::Helpers::UrlHelper

	before_action :logged_in_user, only: [:edit, :new, :index]
	before_action :admin_user,     only: [:create, :new, :edit, :update]

	def index
		if params[:search].present?
			@recipes = Recipe.search(params[:search], {fields: ["title^30", "cuisine^20", "description^1", "ingredient_names^10"]}).results.paginate(:page => params[:page], :per_page => 12)
			if @recipes.empty?
				@no_results = true
				@recipes = Recipe.all.sample(6)
			end
		else
			@recipes = Recipe.all.paginate(:page => params[:page], :per_page => 12)
		end
		@fav_recipes = current_user.favourites
		@fav_recipes_limit = current_user.favourites.first(6)
	end
	def show
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
		@ingredients = @recipe.ingredients
		similar_portions_count = 0
		@portions.each do |portion|
			if Portion.where(recipe_id: params[:id], ingredient_id: portion.ingredient_id).length > 1
				similar_portions_count = similar_portions_count + 1
			end
		end
		if similar_portions_count != 0
			flash.alert = "Looks like there are similar ingredients, #{link_to('edit and combine', edit_recipe_path(@recipe))} these similar ingredients into one and delete the others"
		end
	end
	def favourites
		@fav_recipes = current_user.favourites.paginate(:page => params[:page], :per_page => 12)
	end
	def new
		@recipe = Recipe.new
		# 3.times { @recipe.portions.build}
		@cuisines = Set[]
		Recipe.all.each do |recipe|
			if recipe.cuisine.to_s != ''
				@cuisines.add(recipe.cuisine)
			end
		end
  end
  def create
		@recipe = Recipe.new(recipe_params)
		if @recipe.save
			redirect_to portions_new_path(:recipe_id => @recipe.id)
    else
      render new_recipe_path
    end
	end
	def edit
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
		@units = Unit.all
		@cuisines = Set[]
		Recipe.all.each do |recipe|
			if recipe.cuisine.to_s != ''
				@cuisines.add(recipe.cuisine)
			end
		end
		similar_portions_count = 0
		@portions.each do |portion|
			if Portion.where(recipe_id: params[:id], ingredient_id: portion.ingredient_id).length > 1
				similar_portions_count = similar_portions_count + 1
			end
		end
		if similar_portions_count != 0
			flash.alert = "Looks like there are similar ingredients, combine these similar ingredients into one and delete the others"
		end
	end
	def update
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
		@units = Unit.all

		@portion_ids = []
		@portions.each do |portion|
			@portion_ids.push(portion.id)
		end

		@delete_portion_check_ids = params[:recipe][:portion][:id]
		@form_portion_ids = params[:recipe][:portion_ids]
		@form_portion_amounts = params[:recipe][:portion][:amount]
		@form_portion_ingredient_units = params[:recipe][:portion][:ingredient][:unit]

		# Rails.logger.debug @delete_portion_check_ids
		if @delete_portion_check_ids
			@portion_unpick = Portion.find(@delete_portion_check_ids)
			@portions.delete(@portion_unpick)
		end

		if @form_portion_amounts.length == @portions.length
			@portions.each_with_index do |portion, index|
				if not portion[:amount].to_f == @form_portion_amounts[index].to_f
					portion.update_attributes(
						:amount => @form_portion_amounts[index].to_f
					)
				end
				if @form_portion_ingredient_units.length == @portions.length
					if not portion.ingredient.unit_id.to_f == @form_portion_ingredient_units[index].to_f
						portion.ingredient.update_attributes(
							:unit_id => @form_portion_ingredient_units[index].to_f
						)
					end
				end
			end
		end

		if @recipe.update(recipe_params)
			redirect_to recipe_path(@recipe)
		else
			render 'edit'
		end
	end
	# Add and remove favourite recipes
  # for current_user
  def favourite
		type = params[:type]
		@recipe = Recipe.where(id: params[:id]).first
		recipe_title = @recipe.title.to_s
    if type == "favourite"
			current_user.favourites << @recipe
			@string = "Added the \"#{link_to(@recipe.title, recipe_path(@recipe))}\" recipe to favourites"
      redirect_back fallback_location: root_path, notice: @string

    elsif type == "unfavourite"
			current_user.favourites.delete(@recipe)
			@string = "Removed the \"#{link_to(@recipe.title, recipe_path(@recipe))}\" recipe from favourites"
			redirect_back fallback_location: root_path, notice: @string

    else
      # Type missing, nothing happens
      redirect_back fallback_location: root_path, notice: 'Nothing happened.'
    end
	end
	def add_to_shopping_list
		@recipe = Recipe.find(params[:id])
		recipe_title = @recipe.title

		this_shopping_list = ShoppingList.where(user_id: current_user.id).order('created_at DESC').first_or_create

		this_shopping_list.recipes << @recipe
		@recipe.portions.each do |portion|
			shopping_list_portion = ShoppingListPortion.new(shopping_list_id: this_shopping_list.id, recipe_number: @recipe.id)
			shopping_list_portion.update_attributes(amount: portion.amount, ingredient_id: portion.ingredient_id, unit_number: portion.unit_number)
		end


		# find index of shopping list
		userShoppingLists = current_user.shopping_lists
		zero_base_index = userShoppingLists.index(this_shopping_list)
		shopping_list_index = zero_base_index + 1
		shopping_list_ref = "#" + shopping_list_index.to_s + " " + this_shopping_list.created_at.to_date.to_s(:long)

		# give notice that the recipe has been added with link to shopping list
		@string = "Added the #{@recipe.title} to shopping list from #{link_to(shopping_list_ref, shopping_list_path(this_shopping_list))}"
		redirect_back fallback_location: root_path, notice: @string

	end

	private
		def recipe_params
			params.require(:recipe).permit(:user_id, :search, :cuisine, :search_ingredients, :title, :description, :prep_time, :cook_time, :yield, :note, portions_attributes:[:amount, :_destroy])
		end

		def shopping_list_params
      params.require(:shopping_list).permit(:id, :date_created, recipes_attributes:[:id, :title, :description])
    end

		# Confirms a logged-in user.
		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to root_url
			end
		end

		# Confirms an admin user.
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end
end
