require 'will_paginate/array'
class RecipesController < ApplicationController
	include ActionView::Helpers::UrlHelper
	include ShoppingListsHelper
	include StockHelper
	include UnitsHelper
	include RecipesHelper

	require 'will_paginate/array'

	before_action :authenticate_user!, except: [:index, :show]
	before_action :correct_user_or_admin, 	 only: [:edit, :publish_update, :delete]

	def index

		### setup session record with stock ingredients in
		###  - should update on stock changes
		### setup session record with recipe ingredient cupboard match
		###  - should also update on stock changes

		if user_signed_in?
			@fallback_recipes_unformatted = current_user.user_recipe_stock_matches.order(ingredient_stock_match_decimal: :desc).map{|user_recipe_stock_match| user_recipe_stock_match.recipe if user_recipe_stock_match.recipe && user_recipe_stock_match.recipe.portions.length != 0 && ((user_recipe_stock_match.recipe[:public] && user_recipe_stock_match.recipe[:live]) || user_recipe_stock_match.recipe[:user_id] == current_user[:id]) }.compact
			@fallback_recipes = @fallback_recipes_unformatted.paginate(:page => params[:page], :per_page => 12)
		else
			@fallback_recipes_unformatted = Recipe.where(live: true, public: true)
			@fallback_recipes = @fallback_recipes_unformatted.paginate(:page => params[:page], :per_page => 12)
		end

		if params.has_key?(:search) && params[:search].to_s != ''
			if user_signed_in?
				@recipes = Recipe.where(live: true, public: true).or(Recipe.where(user_id: current_user[:id])).search(params[:search], operator: 'or', fields: ["ingredient_names^12", "title^4", "cuisine^3"]).results.uniq.paginate(:page => params[:page], :per_page => 12)
			else
				@recipes = Recipe.where(live: true, public: true).search(params[:search], operator: 'or', fields: ["ingredient_names^12", "title^4", "cuisine^3"]).results.uniq.paginate(:page => params[:page], :per_page => 12)
			end

			@ingredient_results = Ingredient.search(params[:search],  operator: 'or').results

			@mini_progress_on = true

			if @recipes.empty?
				@no_results = true
				@recipes = @fallback_recipes
			end
		else
			@recipes = @fallback_recipes
		end


		if user_signed_in?
			@fav_recipes = current_user.favourites
			@fav_recipes_limit = current_user.favourites.first(6)
		else
			@fav_recipes = []
			@fav_recipes_limit = []
		end


		recipe_titles = @fallback_recipes_unformatted.map(&:title)
		ingredients = Ingredient.all.map(&:name).uniq

		@recipe_search_autocomplete_list = (recipe_titles + ingredients).sort_by(&:downcase)

		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])

	end


	def show
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
		@ingredients = @recipe.ingredients
		@cuisines = cuisines_list()

		@recipe_cuisine = @recipe.cuisine

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

		if user_signed_in?
			if (@recipe.live != true || @recipe.public != true) && current_user != @recipe.user && !current_user.admin
				redirect_to root_path
			end
			@cupboard_ids = CupboardUser.where(user_id: current_user.id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard.setup == true || cu.cupboard.hidden == true }.compact
			@cupboard_stock_in_date_ingredient_ids = Stock.where(cupboard_id: @cupboard_ids, hidden: false).where("use_by_date >= :date", date: Date.current - 2.days).uniq { |s| s.ingredient_id }.map{ |s| s.ingredient.id }.compact
		elsif @recipe.live != true || @recipe.public != true
			redirect_to root_path
		end

		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
	end

	def favourites
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@fav_recipes = current_user.favourites.paginate(:page => params[:page], :per_page => 12)
	end
	def yours
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		@recipes = current_user.recipes.order("updated_at desc").paginate(:page => params[:page], :per_page => 12)
	end
	def new
		@recipe = Recipe.new
		@units = unit_list()
		@cuisines = cuisines_list()
  end
  def create
		@recipe = Recipe.new(recipe_params)
		@units = unit_list()
		if @recipe.save
			if params.has_key?(:new_recipe_steps)
				params[:new_recipe_steps].each_with_index do |content, index|
					if content.to_s != ''
						step = RecipeStep.create(
							recipe_id: @recipe.id,
							content: content,
							number: index
						)
					end
				end
			end

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
		@units = unit_list()
		@recipe_cuisine = @recipe.cuisine.to_s != '' ? @recipe.cuisine : nil
		@cuisines = cuisines_list()


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

	def add_image
		if not user_signed_in?
			respond_to do |format|
				format.json { render json: {'add recipe image': 'not allowed'}.as_json, status: 400}
				format.html { redirect_to recipes_path }
			end and return
		end

		if not params.has_key?(:image_path)
			respond_to do |format|
				format.json { render json: {'no image path seen': 'not allowed'}.as_json, status: 400}
				format.html { redirect_to recipes_path }
			end and return
		end

		if not params.has_key?(:recipe_id)
			respond_to do |format|
				format.json { render json: {'no recipe id seen': 'not allowed'}.as_json, status: 400}
				format.html { redirect_to recipes_path }
			end and return
		end

		recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
		recipe_id = recipe_id_hash.decode(params[:recipe_id]).first

		if Recipe.exists?(recipe_id) && (current_user.recipes.map(&:id).include?(recipe_id) || current_user.admin)
			recipe = Recipe.find(recipe_id)
			recipe.update_attributes(image_url: params[:image_path].to_s)

			respond_to do |format|
				format.json { render json: {
					status: "recipe image added",
					imageUrl: recipe.image_url
				}.as_json, status: 200}
				format.html {redirect_to recipes_path}
			end and return
		else
			respond_to do |format|
				format.json { render json: {
					status: "recipe not available to edit"
				}.as_json, status: 400}
				format.html {redirect_to recipes_path}
			end and return
		end


	end

	def portion_delete
		if !user_signed_in? || !params.has_key?(:portion_id)
			respond_to do |format|
				format.json { render json: {"status": "not allowed"}.as_json, status: 403}
				format.html {redirect_to recipes_path}
			end and return
		end

		find_portion_for_user = current_user.recipes.map{|r|r.portions}.flatten.select{|p|p.id == params[:portion_id].to_i}

		if find_portion_for_user.length > 0
			find_portion_for_user.map{|p|p.destroy}
			respond_to do |format|
				format.json { render json: {status: "portion deleted"}.as_json, status: 200}
				format.html {redirect_to recipes_path}
			end and return
		elsif current_user.admin == true
			portion = Portion.where(id: params[:portion_id].to_i)
			if portion.length > 0
				portion.first.destroy
				respond_to do |format|
					format.json { render json: {status: "portion deleted"}.as_json, status: 200}
					format.html {redirect_to recipes_path}
				end and return
			else
				respond_to do |format|
					format.json { render json: {"status": "portion not found"}.as_json, status: 404}
					format.html {redirect_to recipes_path}
				end and return
			end
		else
			respond_to do |format|
				format.json { render json: {"status": "portion not found"}.as_json, status: 404}
				format.html {redirect_to recipes_path}
			end and return
		end

	end

	def update
		@recipe = Recipe.find(params[:id])
		@portions = @recipe.portions
		@units = unit_list()

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

		if params[:recipe].has_key?(:steps)
			@recipe.steps.destroy_all
			params[:recipe][:steps].to_unsafe_h.map.with_index {|(step_id, contents), i|
				next if contents["content"].blank?
				@recipe.steps.create(content: contents["content"], number: i)
			}
		end

		if params.has_key?(:new_recipe_steps)
			params[:new_recipe_steps].map do |content|
				if content.to_s != ''
					step = RecipeStep.create(
						recipe_id: @recipe.id,
						content: content,
						number: @recipe.steps.length > 0 ? (@recipe.steps.where.not(number: nil).order(:number).last.number + 1) : 0
					)
				end
			end
		end

		if params.has_key?(:redirect) && params[:redirect].to_s != ''
			@recipe.update(recipe_params.except(:user_id))
			if @recipe.steps.length == 0 || @recipe.cook_time.to_s == '' || @recipe.portions.length == 0
				@recipe.update_attributes(live: false)
			end
			redirect_to portions_new_path(:recipe_id => params[:id])
			Recipe.reindex
			update_recipe_stock_matches(nil, nil, @recipe.id)
		else
			if @recipe.update(recipe_params.except(:user_id))
				if @recipe.steps.length == 0 || @recipe.cook_time.to_s == '' || @recipe.portions.length == 0
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

	def update_recipe_matches
		return head(:forbidden) unless user_signed_in?
		update_recipe_stock_matches_core
	end

	def publish_update
		unless (params.has_key?(:type) && params.has_key?(:id))
			redirect_to recipes_path, notice: "Something went wrong. That recipe change didn't go through"
			return
		end

		type = params[:type]
		@recipe = Recipe.where(id: params[:id]).first
		if type == 'make_live'
			@recipe.update_attributes(live: true)
			@string = "#{@recipe.title} is now live!"
			redirect_back fallback_location: recipes_path, notice: @string
		elsif type == 'make_draft'
			@recipe.update_attributes(live: false)
			@string = "#{@recipe.title} is now in draft mode"
			redirect_back fallback_location: recipes_path, notice: @string
			if @recipe.public
				@recipe.update_attributes(public: false)
			end
		elsif type == 'make_public' && @recipe.live
			@recipe.update_attributes(public: true)
			@string = "#{@recipe.title} is live and public"
			redirect_back fallback_location: recipes_path, notice: @string
		elsif type == 'make_private' && @recipe.live
			@recipe.update_attributes(public: false)
			@string = "#{@recipe.title} is live and private"
			redirect_back fallback_location: recipes_path, notice: @string
		else
			redirect_back fallback_location: recipes_path, notice: "Something went wrong. That recipe change didn't go through"
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
		if not user_signed_in?
			redirect_back fallback_location: recipes_path, notice: 'You need to sign up or sign in, before being able to favourite a recipe'
			return
		end

		type = params[:type]
		@recipe = Recipe.where(id: params[:id]).first
		recipe_title = @recipe.title.to_s
    if type == "favourite"
			current_user.favourites << @recipe
			@string = "Added the \"#{link_to(@recipe.title, recipe_path(@recipe))}\" recipe to favourites"
      redirect_back fallback_location: recipes_path, notice: @string

    elsif type == "unfavourite"
			current_user.favourites.delete(@recipe)
			@string = "Removed the \"#{link_to(@recipe.title, recipe_path(@recipe))}\" recipe from favourites"
			redirect_back fallback_location: recipes_path, notice: @string

    else
      # Type missing, nothing happens
      redirect_back fallback_location: recipes_path, notice: 'Nothing happened.'
    end
	end

	private
		def recipe_params
			params.require(:recipe).permit(:user_id, :image_url, :steps, :portions, :search, :live, :public, :cuisine, :search_ingredients, :title, :prep_time, :cook_time, :yield, :note, portions_attributes:[:amount, :unit_id, :ingredient_id, :recipe_id, :_destroy], steps_attributes: [:content])
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
