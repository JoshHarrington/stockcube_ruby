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
	end
	def search

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



		#####
		if params[:recipes] or (params[:recipes] and params[:cuisine]) or params[:cuisine]
			Rails.logger.debug 'recipe params = ' + params[:recipes]
			Rails.logger.debug 'cuisine params = ' + params[:cuisine]
			if params[:ingredients]
				Rails.logger.debug 'ingredients params = ' + params[:ingredients]
			end
		end
		if params[:ingredients]
			Rails.logger.debug params[:ingredients]
			Rails.logger.debug 'ingredients params = ' + params[:ingredients]
		end
		if not params[:recipes] or params[:cuisine] or params[:ingredients]
			Rails.logger.debug '__nothing to see here__'
		end

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
