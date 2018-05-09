require 'will_paginate/array'
class RecipesController < ApplicationController
	include ActionView::Helpers::UrlHelper

	before_action :logged_in_user, only: [:index, :edit, :new]
	before_action :user_has_recipes, only: :index
	before_action :admin_user,     only: [:create, :new, :edit, :update]

	def index
		@recipes = Recipe.paginate(:page => params[:page], :per_page => 20)
		@fallback_recipes = Recipe.all.sample(4)
		@your_recipes_length = current_user.favourites.length
		@your_recipes_sample = current_user.favourites.first(4)

		@cuisines = Set[]
		Recipe.all.each do |recipe|
			if recipe.cuisine
				@cuisines.add(recipe.cuisine)
			end
		end

		@cuisines = @cuisines.to_a.sort_by{ |c| c.to_s.downcase }

		@ingredients = Set[]
		Recipe.all.each do |recipe|
			if recipe.ingredients.first
				recipe.ingredients.each do |ingredient|
					@ingredients.add(ingredient.name)
				end
			end
		end

		@ingredients = @ingredients.to_a.sort_by{ |c| c.to_s.downcase }
		@ingredients = @ingredients.reject {|a| @ingredients.any? {|b| b != a and b =~ /#{a}/}}
	end
	def search
		@recipes = Recipe.all
		@cuisines = Set[]
		Recipe.all.each do |recipe|
			if recipe.cuisine
				@cuisines.add(recipe.cuisine)
			end
		end

		@cuisines = @cuisines.to_a.sort_by{ |c| c.to_s.downcase }

		@ingredients = Set[]
		Recipe.all.each do |recipe|
			if recipe.ingredients.first
				recipe.ingredients.each do |ingredient|
					if ingredient.searchable == true
						@ingredients.add(ingredient.name)
					end
				end
			end
		end

		@ingredients = @ingredients.to_a.sort_by{ |c| c.to_s.downcase }
		@ingredients = @ingredients.reject {|a| @ingredients.any? {|b| b != a and b =~ /#{a}/}}

		if params.has_key?(:recipes)
			Rails.logger.debug '!!** recipe params = ' + params[:recipes].to_s
			@title_search_recipes = Set[]
			searched_recipes = Recipe.where("lower(title) LIKE :search", search: "%#{params[:recipes].to_s.downcase}%")
			searched_recipes.each do |recipe|
				@title_search_recipes.add(recipe)
			end
		end

		if params.has_key?(:cuisine)
			Rails.logger.debug '!!** cuisine params = ' + params.has_key?(:cuisine).to_s
			@cuisine_search_recipes = Set[]
			searched_recipes = Recipe.where("lower(cuisine) LIKE :search", search: "%#{params[:cuisine].to_s.downcase}%")
			searched_recipes.each do |recipe|
				@cuisine_search_recipes.add(recipe)
			end
		end

		if @cuisine_search_recipes && @title_search_recipes
			@final_recipes = @cuisine_search_recipes.to_a & @title_search_recipes.to_a
		elsif @cuisine_search_recipes
			@final_recipes = @cuisine_search_recipes.to_a
		elsif @title_search_recipes
			@final_recipes = @title_search_recipes.to_a
		end

		Rails.logger.debug '!!** final recipes = ' + @final_recipes.to_s

		# if params.has_key?(:recipes) && params.has_key?(:cuisine)
		# 	@final_recipes = @title_search_recipes.to_a & @cuisine_search_recipes.to_a
		# end
		# if params.has_key?(:recipes) && !params.has_key?(:cuisine)
		# 	@final_recipes = @title_search_recipes.to_a
		# end
		# if !params.has_key?(:recipes) && params.has_key?(:cuisine)
		# 	@final_recipes = @cuisine_search_recipes.to_a
		# end

		if params.has_key?(:ingredients)
			ingredient_search = params[:ingredients]
			@ingredients_search_recipes = Set[]
			@ingredients_from_search = Set[]
			Rails.logger.debug '!!** ingredients params = ' + params[:ingredients].to_s
			if params[:ingredients].include?('|')
				ingredient_search_array = ingredient_search.to_s.split('|')
				ingredient_search_array.collect(&:strip!)
				ingredient_search_array.each do |ingredient_name|
					ingredients_lookup = Ingredient.where('searchable' => true).where("lower(name) LIKE :ingredient_search", ingredient_search: "%#{ingredient_name.downcase}%")
					# ingredients_lookup = Ingredient.where("lower(name) LIKE :ingredient_search", ingredient_search: "%#{ingredient_name.downcase}%")
					ingredients_lookup.each do |ingredient|
						@ingredients_from_search.add(ingredient)
					end
				end
			else
				ingredients_lookup = Ingredient.where('searchable' => true).where("lower(name) LIKE :ingredient_search", ingredient_search: "%#{ingredient_search.downcase}%")
				# ingredients_lookup = Ingredient.where("lower(name) LIKE :ingredient_search", ingredient_search: "%#{ingredient_search.downcase}%")
				ingredients_lookup.each do |ingredient|
					@ingredients_from_search.add(ingredient)
				end
			end


			@finalSet = Set[]

			@recipes.each do |recipe|
				@ingredients_from_search.each do |ingredient|
					recipe.portions.each do |portion|
						if portion.ingredient_id == ingredient.id
							@finalSet.add(recipe)
						end
					end
				end
			end

			# @recipes.each do |recipe|
			# 	firstSet = Set[]
			# 	laterSet = Set[]
			# 	@ingredients_from_search.each_with_index do |ingredient, index|
			# 		if index == 0
			# 			recipe.portions.each do |portion|
			# 				if portion.ingredient_id == ingredient.id
			# 					firstSet.add(recipe)
			# 				end
			# 			end
			# 		else
			# 			recipe.portions.each do |portion|
			# 				if portion.ingredient_id == ingredient.id
			# 					laterSet.add(recipe)
			# 				end
			# 			end
			# 		end
			# 	end
			# 	if laterSet
			# 		@finalSet = firstSet.to_a & laterSet.to_a
			# 	else
			# 		@finalSet = firstSet.to_a
			# 	end
			# end
		end

		Rails.logger.debug 'final ingredient set = ' + @finalSet.to_s

		if @final_recipes && @finalSet.to_s != ''
			@final_recipes = @final_recipes & @finalSet.to_a
		elsif @finalSet.to_s != ''
			@final_recipes = @finalSet.to_a
		end

		@final_recipes = @final_recipes.sort_by{ |c| c.to_s.downcase }.paginate(:page => params[:page], :per_page => 20)
		## if no recipes matching, remove cuisine and ingredients to try and provide results
		## show feedback that there are no recipes with that string in title even with cuisine and ingredients removed






		# #####
		# if params[:recipes] || (params[:recipes] and params.has_key?(:cuisine)) || params.has_key?(:cuisine)
		# 	@final_recipes = Recipe.search(@recipe_cuisine_joint_search).order('created_at DESC').paginate(:page => params[:page], :per_page => 20)

		# 	if params[:recipes]
		# 		# Rails.logger.debug 'recipe params = ' + params[:recipes]
		# 	end
		# 	if params.has_key?(:cuisine)
		# 		# Rails.logger.debug 'cuisine params = ' + params.has_key?(:cuisine)
		# 	end
		# 	if params[:ingredients]
		# 		# Rails.logger.debug 'ingredients params = ' + params[:ingredients]
		# 	end
		# end
		# if params[:ingredients]
		# 	Rails.logger.debug params[:ingredients]
		# 	# Rails.logger.debug 'ingredients params = ' + params[:ingredients]
		# end
		# if not params[:recipes] or params.has_key?(:cuisine) or params[:ingredients]
		# 	# Rails.logger.debug '__nothing to see here__'
		# end

		#####




		# _Resolved search method_
		## should only take one params search
		## then split the string based on commas, stripping out everything that isn't words
		#### should it expect that strings are always separated by commas or that each word should be searched separately?

		## then search through all recipes [title, cuisine, description?] and return ones that match, create set of matching recipes
		## make list of search strings that are not recipe [title, cuisine, description?]
		## these search strings should be expected to be ingredients
		## find matching ingredients set
		## of the matched recipes set, search through them to find those which contain all ingredients mentioned
		## remove all search strings (that could be matched to something in the database) and display them below the search as removable tags
		## if the tags are removed then a new search should be run to update the results, could be done with ajax

		# if params[:search]
		# 	@recipes = Recipe.search(params[:search]).order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
		# 	if params[:search_ingredients]
		# 		@ingredient_ids_from_search = []
		# 		ingredient_search = params[:search_ingredients]
		# 		if ingredient_search.to_s.include? ','
		# 			ingredient_search_array = ingredient_search.to_s.split(',')
		# 			ingredient_search_array.collect(&:strip!)
		# 			ingredient_search_array.each do |ingredient_name|
		# 				ingredients_from_search = Ingredient.where("lower(name) LIKE :ingredient_search", ingredient_search: "%#{ingredient_name.downcase}%")
		# 				ingredients_from_search.each do |ingredient|
		# 					@ingredient_ids_from_search << ingredient.id
		# 				end
		# 			end
		# 		else
		# 			ingredients_from_search = Ingredient.where("lower(name) LIKE :ingredient_search", ingredient_search: "%#{ingredient_search.downcase}%")
		# 			ingredients_from_search.each do |ingredient|
		# 				@ingredient_ids_from_search << ingredient.id
		# 			end
		# 		end
		# 		@final_recipes = Set[]
		# 		@recipes.each do |recipe|
		# 			recipe.portions.each do |portion|
		# 				@ingredient_ids_from_search.each do |ingredient_id_from_search|
		# 					if portion.ingredient_id == ingredient_id_from_search
		# 						@final_recipes.add(recipe)
		# 					end
		# 				end
		# 			end
		# 		end
		# 		if @final_recipes.length > 1
		# 			@final_recipes = @final_recipes.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
		# 		end
		# 	else
		# 		@final_recipes = @recipes
		# 	end
		# else
		# 	@final_recipes = Recipe.all.order('created_at DESC')
		# end
		@fallback_recipes = Recipe.all.sample(4)
	end
	def show
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
		@ingredients = @recipe.ingredients
	end
	def favourites
		@your_recipes = current_user.favourites.paginate(:page => params[:page], :per_page => 5)
	end
	def new
		@recipe = Recipe.new
  end
  def create
    @recipe = Recipe.new(recipe_params)
    if @recipe.save
      redirect_to '/recipes'
    else
      render 'new'
    end
	end
	def edit
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
	end
	def update
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
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
		@recipe = Recipe.where(id: params[:id])
		recipe_title = @recipe.title
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

		puts this_shopping_list.to_s + ' this shopping list'
		puts @recipe.to_s + ' the recipe'

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
			params.require(:recipe).permit(:user_id, :search, :search_ingredients, :title, :description, portions_attributes:[:id, :amount, :_destroy], ingredients_attributes:[:id, :name, :image, :unit, :_destroy])
		end

		def shopping_list_params
      params.require(:shopping_list).permit(:id, :date_created, recipes_attributes:[:id, :title, :description, :_destroy])
    end

		# Confirms a logged-in user.
		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to search_recipe_path
			end
		end

		def user_has_recipes
			unless current_user.favourites.first
				redirect_to search_recipe_path
			end
		end

		# Confirms an admin user.
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end
end
