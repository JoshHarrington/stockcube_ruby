require 'will_paginate/array'
class RecipesController < ApplicationController
	include ActionView::Helpers::UrlHelper
	include ShoppingListsHelper

	require 'will_paginate/array'

	before_action :logged_in_user, only: [:edit, :new, :index]
	before_action :admin_user,     only: [:create, :new, :edit, :update]

	def index

		### setup session record with stock ingredients in
		###  - should update on stock changes
		### setup session record with recipe ingredient cupboard match
		###  - should also update on stock changes

		if params.has_key?(:search) && params[:search].to_s != ''
			recipe_results = Recipe.search(params[:search], {fields: ["title^30", "cuisine^20", "description^1", "ingredient_names^10"]}, operator: 'or').results

			recipes_ids_array = recipe_results.map(&:id)

			@recipes = current_user.user_recipe_stock_matches.where(recipe_id: recipes_ids_array).order(ingredient_stock_match_decimal: :desc).map{|user_recipe_stock_match| user_recipe_stock_match.recipe}.paginate(:page => params[:page], :per_page => 12)

			# picked_recipe_ingredient_cupboard_matches = session[:recipe_ingredient_cupboard_matches].slice(*recipes_ids_array)

			# recipe_ids_sorted = picked_recipe_ingredient_cupboard_matches.sort_by { |id, values | values[0] }.reverse!.map{|r| r[0]}
			# @recipes = Recipe.find(recipe_ids_sorted).paginate(:page => params[:page], :per_page => 12)

			if @recipes.empty?
				@no_results = true
				@recipes = Recipe.all.sample(12)
			end
		else
			# recipes = Recipe.all

			@recipes = current_user.user_recipe_stock_matches.order(ingredient_stock_match_decimal: :desc).map{|user_recipe_stock_match| user_recipe_stock_match.recipe}.paginate(:page => params[:page], :per_page => 12)
			# @recipes = Recipe.find(recipe_ids_sorted).paginate(:page => params[:page], :per_page => 12)
		end
		@fav_recipes = current_user.favourites
		@fav_recipes_limit = current_user.favourites.first(6)
	end


	def show
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
		@ingredients = @recipe.ingredients
		### checking for duplicate ingredients should be done once as a rake task and the database updated
		# similar_portions_count = 0
		# @portions.each do |portion|
		# 	if Portion.where(recipe_id: params[:id], ingredient_id: portion.ingredient_id).length > 1
		# 		similar_portions_count = similar_portions_count + 1
		# 	end
		# end
		# if similar_portions_count != 0
		# 	flash.alert = "Looks like there are similar ingredients, #{link_to('edit and combine', edit_recipe_path(@recipe))} these similar ingredients into one and delete the others"
		# end

		@cupboard_ids = CupboardUser.where(user_id: current_user.id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard.setup == true || cu.cupboard.hidden == true }.compact
		@cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: @cupboard_ids).where("use_by_date >= :date", date: Date.current - 2.days).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact

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

		shopping_list_portions_set(@recipe.id, nil, current_user.id, nil)

		# give notice that the recipe has been added with link to shopping list
		if current_user.shopping_lists.length > 0 && current_user.shopping_lists.last.archived != true && current_user.shopping_lists.last.recipes.length > 0
			@string = "Added the '#{@recipe.title}' to your #{link_to("current shopping list", current_shopping_list_ingredients_path)}"
			redirect_back fallback_location: recipes_path, notice: @string
		end

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
