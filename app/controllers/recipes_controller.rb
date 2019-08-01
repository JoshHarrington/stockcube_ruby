require 'will_paginate/array'
class RecipesController < ApplicationController
	include ActionView::Helpers::UrlHelper
	include ShoppingListsHelper
	include StockHelper

	require 'will_paginate/array'

	before_action :logged_in_user, only: [:edit, :new, :index]
	before_action :correct_user_or_admin, 	 only: [:edit, :publish_update, :delete]

	def index

		### setup session record with stock ingredients in
		###  - should update on stock changes
		### setup session record with recipe ingredient cupboard match
		###  - should also update on stock changes

		@fallback_recipes_unformatted = current_user.user_recipe_stock_matches.order(ingredient_stock_match_decimal: :desc).map{|user_recipe_stock_match| user_recipe_stock_match.recipe if user_recipe_stock_match.recipe && user_recipe_stock_match.recipe.portions.length != 0 && (user_recipe_stock_match.recipe[:public] || user_recipe_stock_match.recipe[:user_id] == current_user[:id]) }.compact
		@fallback_recipes = @fallback_recipes_unformatted.paginate(:page => params[:page], :per_page => 12)

		if params.has_key?(:search) && params[:search].to_s != ''
			@recipes = Recipe.search(params[:search], operator: 'or', fields: ["ingredient_names^12", "title^4", "cuisine^3", "description^1"]).results.uniq.paginate(:page => params[:page], :per_page => 12)

			@ingredient_results = Ingredient.search(params[:search],  operator: 'or').results

			@mini_progress_on = true

			if @recipes.empty?
				@no_results = true
				@recipes = @fallback_recipes
			end
		else
			@recipes = @fallback_recipes
		end
		@fav_recipes = current_user.favourites
		@fav_recipes_limit = current_user.favourites.first(6)


		recipe_titles = @fallback_recipes_unformatted.map(&:title)
		ingredients = Ingredient.all.map(&:name).uniq

		@recipe_search_autocomplete_list = (recipe_titles + ingredients).sort_by(&:downcase)

		if UserRecipeStockMatch.where(user_id: current_user[:id]).order("updated_at desc").first.updated_at < 12.hours.ago
			flash[:sticky_recipe] = %Q[Looks like it's been a while since your recipe list got updated based on your stock, would you like to do that now? <br/><a class="button" href="/recipes/update_matches">Yes, update!</a> <button class="button button-secondary dismiss_no_update recipe_no_update_cookie_set">No thanks</button>]
		end

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
		@cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: @cupboard_ids, hidden: false).where("use_by_date >= :date", date: Date.current - 2.days).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact

	end
	def favourites
		@fav_recipes = current_user.favourites.paginate(:page => params[:page], :per_page => 12)
	end
	def yours
		@recipes = current_user.recipes.order("updated_at desc").paginate(:page => params[:page], :per_page => 12)
	end
	def new
		@recipe = Recipe.new
		@units = Unit.all
		@cuisines = Recipe.all.map{|r| r[:cuisine] if !(r[:cuisine].nil? || r[:cuisine].empty? )}.compact.uniq.compact.sort
  end
  def create
		@recipe = Recipe.new(recipe_params)
		@units = Unit.all
		@cuisines = Recipe.all.map{|r| r[:cuisine] if !(r[:cuisine].nil? || r[:cuisine].empty? )}.compact.uniq.compact.sort
		if @recipe.save
			if params.has_key?(:redirect) && params[:redirect].to_s != ''
				redirect_to portions_new_path(:recipe_id => @recipe.id)
			else
				redirect_to recipe_path(@recipe.id)
			end
		else
			render new_recipe_path(:anchor => 'recipe_title_container')
		end
		if @recipe.live
			Recipe.reindex
			update_recipe_stock_matches(nil, nil, @recipe.id)
		end
	end
	def edit
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions.order("created_at ASC")
		@units = Unit.all
		@recipe_cuisine = @recipe.cuisine.to_s != '' ? @recipe.cuisine : nil
		@cuisines = Recipe.all.map{|r| r[:cuisine] if !(r[:cuisine].nil? || r[:cuisine].empty? )}.compact.uniq.compact.sort

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

		@delete_portion_check_ids = params[:recipe][:portion_delete_ids]

		## delete portions from :portion_delete_ids
		if @delete_portion_check_ids
			Portion.find(@delete_portion_check_ids).map{|p| p.delete }
		end

		if @portions.length > 0
			params[:recipe][:portions].to_unsafe_h.map do |portion_id, values|
				next if @delete_portion_check_ids && @delete_portion_check_ids.include?(portion_id)
				portion = Portion.find(portion_id)
				unless portion.amount == values[:amount].to_f
					portion.update_attributes(
						amount: values[:amount]
					)
				end
				unless portion.unit_id == values[:unit_id].to_f
					portion.update_attributes(
						unit_id: values[:unit_id]
					)
				end
			end
		end

		if params.has_key?(:redirect) && params[:redirect].to_s != ''
			@recipe.update(recipe_params.except(:user_id))
			if @recipe.description.to_s == '' || @recipe.cook_time.to_s == '' || @recipe.portions.length == 0
				@recipe.update_attributes(live: false)
			end
			redirect_to portions_new_path(:recipe_id => params[:id])
			Recipe.reindex
			update_recipe_stock_matches(nil, nil, @recipe.id)
		else
			if @recipe.update(recipe_params.except(:user_id))
				if @recipe.description.to_s == '' || @recipe.cook_time.to_s == '' || @recipe.portions.length == 0
					@recipe.update_attributes(live: false)
				end
				redirect_to recipe_path(@recipe)
				if @recipe.live
					update_recipe_stock_matches(nil, nil, @recipe.id)
				end
				Recipe.reindex
				update_recipe_stock_matches(nil, nil, @recipe.id)
			else
				render 'edit'
			end
		end
	end

	def update_recipe_stock_matches_method
		update_recipe_stock_matches
		redirect_back fallback_location: recipes_path
	end

	def publish_update
		type = params[:type]
		@recipe = Recipe.where(id: params[:id]).first
		if type == 'make_live'
			@recipe.update_attributes(live: true)
			@string = "#{@recipe.title} is now live!"
			redirect_back fallback_location: root_path, notice: @string
		elsif type == 'make_draft'
			@recipe.update_attributes(live: false)
			@string = "#{@recipe.title} is now in draft mode"
			redirect_back fallback_location: root_path, notice: @string
			if @recipe.public
				@recipe.update_attributes(public: false)
			end
		elsif type == 'make_public' && @recipe.live
			@recipe.update_attributes(public: true)
			@string = "#{@recipe.title} is live and public"
			redirect_back fallback_location: root_path, notice: @string
		elsif type == 'make_private' && @recipe.live
			@recipe.update_attributes(public: false)
			@string = "#{@recipe.title} is live and private"
			redirect_back fallback_location: root_path, notice: @string
		else
			redirect_back fallback_location: root_path
		end
	end

	def delete
		@recipe = Recipe.find(params[:id])
		@recipe.portions.destroy_all
		@recipe.destroy
		flash[:info] = %Q[Recipe "#{@recipe.title}" deleted]
		if current_user.recipes.length > 0
			redirect_to your_recipes_path
		else
			redirect_to recipes_path
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

		if @recipe.portions.length > 0
			recipe_title = @recipe.title

			shopping_list_portions_set_from_recipes(@recipe.id, nil, current_user.id, nil)

			# give notice that the recipe has been added with link to shopping list
			if current_user.shopping_lists.length > 0 && current_user.shopping_lists.order('updated_at asc').last[:archived] === false && current_user.shopping_lists.order('updated_at asc').last.recipes.length > 0
				@string = "Added the '#{@recipe.title}' to your #{link_to("current shopping list", shopping_lists_current_shop_path)}"
				redirect_back fallback_location: recipes_path, notice: @string
			end
		else
			@string = %Q[That recipe's not ready to be used to build a shopping list, you need to #{link_to("add some ingredients", edit_recipe_path(@recipe))}]
			redirect_back fallback_location: recipes_path, notice: @string
		end

	end

	private
		def recipe_params
			params.require(:recipe).permit(:user_id, :search, :live, :public, :cuisine, :search_ingredients, :title, :description, :prep_time, :cook_time, :yield, :note, portions_attributes:[:amount, :unit_id, :ingredient_id, :recipe_id, :_destroy])
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

		# Confirms an correct user.
		def correct_user_or_admin
			recipe_user_id = Recipe.find(params[:id])[:user_id]
			redirect_to(recipes_path) unless current_user[:id] == recipe_user_id || current_user.admin?
		end

		# Confirms an admin user.
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end
end
