class IngredientsController < ApplicationController
	before_action :authenticate_user!
	before_action :admin_user

	include UnitsHelper

	def index
		@ingredients = Ingredient.all
	end
	def show
		@ingredient = Ingredient.find(params[:id])
		@recipes = @ingredient.recipes
		@cupboards = @ingredient.cupboards
		@portions = @ingredient.portions
	end
	def new
    @ingredient = Ingredient.new
		@units = unit_list()
  end
  def create
		@ingredient = Ingredient.new(ingredient_params)
		@units = unit_list()
    if @ingredient.save
			redirect_to ingredients_path
			Ingredient.reindex
    else
      render 'new'
    end
	end
	def edit
		@ingredient = Ingredient.find(params[:id])
		@portions = @ingredient.portions
		@units = unit_list()
	end
	def update
		ingredient = Ingredient.find(params[:id])

		if params.has_key?(:default_ingredient_sizes)
			sizes_hash = params[:default_ingredient_sizes].to_unsafe_h
			sizes_hash.map do |size_id, values|
				if size_id === "new"
					values.each do |value|
						if value["amount"].to_f != 0.0
							ingredient.default_ingredient_sizes.create(
								amount: value["amount"],
								unit_id: value["unit_id"]
							)
						end
					end
				else
					if ingredient.default_ingredient_sizes.where(id: size_id).length > 0
						ingredient.default_ingredient_sizes.where(id: size_id).first.update_attributes(
							amount: values["amount"],
							unit_id: values["unit_id"]
						)
					end
				end
			end
		end

		if ingredient.update(ingredient_params)
			redirect_to ingredients_path
			Ingredient.reindex
		else
			render 'edit'
		end
	end

	def default_size_update
	end

	protected
		def ingredient_params
			params.require(:ingredient).permit(:name, :searchable, :vegan, :vegetarian, :gluten_free, :dairy_free, :kosher)
		end

		# Confirms an admin user.
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end

end


