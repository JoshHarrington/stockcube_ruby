require 'will_paginate/array'
class RecipesController < ApplicationController
	include ActionView::Helpers::UrlHelper

	before_action :logged_in_user, only: [:edit, :new]
	before_action :admin_user,     only: [:create, :new, :edit, :update]

	def index
		@recipes = Recipe.paginate(:page => params[:page], :per_page => 10)
		@fallback_recipes = Recipe.all.sample(4)
		if current_user && current_user.favourites
			@your_recipes_length = current_user.favourites.length
			@your_recipes_sample = current_user.favourites.first(4)
		end

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

		@title_search_recipes = Set[]
		@cuisine_search_recipes = Set[]
		@ingredients_search_recipes = Set[]

		if params.has_key?(:recipes) && params[:recipes].to_s != ''
			Rails.logger.debug '!!** recipe params = ' + params[:recipes].to_s
			searched_recipes = Recipe.where("lower(title) LIKE :search", search: "%#{params[:recipes].to_s.downcase}%")
			searched_recipes.each do |recipe|
				@title_search_recipes.add(recipe)
			end
		end

		if params.has_key?(:cuisine) && params[:cuisine].to_s != ''
			Rails.logger.debug '!!** cuisine params = ' + params.has_key?(:cuisine).to_s
			searched_recipes = Recipe.where("lower(cuisine) LIKE :search", search: "%#{params[:cuisine].to_s.downcase}%")
			searched_recipes.each do |recipe|
				@cuisine_search_recipes.add(recipe)
			end
		end

		if params.has_key?(:ingredients) && params[:ingredients].to_s != ''
			ingredient_search = params[:ingredients]

			@ingredients_from_search = Set[]
			@first_ingredient_search_recipes = Set[]

			if params[:ingredients].include?('|') || params[:ingredients].include?('%7')
				ingredient_search_array = ingredient_search.to_s.split('|')
				ingredient_search_array.collect(&:strip!)
				ingredient_search_array.each do |ingredient_name|
					ingredients_lookup = Ingredient.where('searchable' => true).where("lower(name) LIKE :ingredient_search", ingredient_search: "%#{ingredient_name.downcase}%")
					@first_ingredient = ingredients_lookup.first
					ingredients_lookup.each do |ingredient|
						@ingredients_from_search.add(ingredient)
					end
				end
			else
				ingredients_lookup = Ingredient.where('searchable' => true).where("lower(name) LIKE :ingredient_search", ingredient_search: "%#{ingredient_search.downcase}%")
				@first_ingredient = ingredients_lookup.first
				ingredients_lookup.each do |ingredient|
					@ingredients_from_search.add(ingredient)
				end
			end

			@recipes_to_check = Set[]

			@recipes.each do |recipe|
				recipe.portions.each do |portion|
					@ingredients_from_search.each do |ingredient|
						if portion.ingredient_id == ingredient.id
							@ingredients_search_recipes.add(recipe)
						end
					end
					if portion.ingredient_id == @first_ingredient.id
						@first_ingredient_search_recipes.add(recipe)
					end
				end
			end
		end


		@title_cuisine_ingredients_combo = Set[]
		@title_cuisine_combo = Set[]
		@title_ingredients_combo = Set[]
		@cuisine_ingredients_combo = Set[]


		if params.has_key?(:recipes) && params[:recipes].to_s != ''
			if params.has_key?(:cuisine) && params[:cuisine].to_s != ''
				if params.has_key?(:ingredients) && params[:ingredients].to_s != ''
					# 3 - title + cuisine + ingredients
					@final_recipes = @title_search_recipes.to_a & @cuisine_search_recipes.to_a & @ingredients_search_recipes.to_a
				else
					# 2 - title + cuisine only
					@final_recipes = @title_search_recipes.to_a & @cuisine_search_recipes.to_a
				end
			elsif params.has_key?(:ingredients) && params[:ingredients].to_s != ''
				# 4 - title + ingredients only
				@final_recipes = @title_search_recipes.to_a & @ingredients_search_recipes.to_a
			else
				@final_recipes = @title_search_recipes
				# 1 - just title
			end
		elsif params.has_key?(:cuisine) && params[:cuisine].to_s != ''
			if params.has_key?(:ingredients) && params[:ingredients].to_s != ''
				# 6 - cuisine and ingredients only
				@final_recipes = @cuisine_search_recipes.to_a & @ingredients_search_recipes.to_a
			else
				# 5 - just cuisine
				@final_recipes = @cuisine_search_recipes
			end
		elsif params.has_key?(:ingredients) && params[:ingredients].to_s != ''
			# 7 - just ingredients
			@final_recipes = @ingredients_search_recipes
		end

		if params.has_key?(:recipes) && params[:recipes].to_s != '' && params.has_key?(:cuisine) && params[:cuisine].to_s != '' && params.has_key?(:ingredients) && params[:ingredients].to_s != ''
			# 3 - title + cuisine + ingredients
			@title_cuisine_ingredients_combo = @title_search_recipes.to_a & @cuisine_search_recipes.to_a & @ingredients_search_recipes.to_a
		end
		if params.has_key?(:recipes) && params[:recipes].to_s != '' && params.has_key?(:cuisine) && params[:cuisine].to_s != ''
			# 2 - title + cuisine
			@title_cuisine_combo = @title_search_recipes.to_a & @cuisine_search_recipes.to_a
		end
		if params.has_key?(:recipes) && params[:recipes].to_s != '' && params.has_key?(:ingredients) && params[:ingredients].to_s != ''
			# 4 - title + ingredients
			@title_ingredients_combo = @title_search_recipes.to_a & @ingredients_search_recipes.to_a
		end
		if params.has_key?(:cuisine) && params[:cuisine].to_s != '' && params.has_key?(:ingredients) && params[:ingredients].to_s != ''
			# 6 - cuisine and ingredients
			@cuisine_ingredients_combo = @cuisine_search_recipes.to_a & @ingredients_search_recipes.to_a
		end

		all_params = params
		selected_params = all_params.slice!(:recipes, :cuisine, :ingredients)

		@cleaned_params = []
		selected_params.values.each do |value|
			if value != ''
				@cleaned_params.push(value)
			end
		end

		@number_of_params = @cleaned_params.length

		@all_recipe_searches = [
			@title_search_recipes.to_a,
			@title_cuisine_combo.to_a,
			@title_cuisine_ingredients_combo.to_a,
			@title_ingredients_combo.to_a,
			@cuisine_search_recipes.to_a,
			@cuisine_ingredients_combo.to_a,
			@ingredients_search_recipes.to_a
		]

		if @final_recipes.present?
			@final_recipes = @final_recipes.sort_by{ |c| c.to_s.downcase }.paginate(:page => params[:page], :per_page => 10)
			if @number_of_params > 1
				if @final_recipes.length < 2
					@find_max_length_array = true
					@final_recipes = @all_recipe_searches.max_by{|x|x.length}
					@all_recipe_searches.each_with_index do |recipes_searches, index|
						if @final_recipes == recipes_searches
							@which_recipe_search_won = index
						end
					end

					@final_recipes = @final_recipes.sort_by{ |c| c.to_s.downcase }.paginate(:page => params[:page], :per_page => 10)
					puts
				end
			end
		else
			@final_recipes = Recipe.all.paginate(:page => params[:page], :per_page => 10)
			@fallback = true
		end

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

		# Confirms an admin user.
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end
end
