class StaticPagesController < ApplicationController
	def home
	end
	def logo
		unless current_user && logged_in? && current_user.admin
			redirect_to root_path
		end
	end
	def about
	end
	def dashboard
		@recipes_order_by_least_wasteful = current_user.user_recipe_stock_matches.order(waste_saving_rating: :desc).map{|user_recipe_stock_match| user_recipe_stock_match.recipe if user_recipe_stock_match.recipe && user_recipe_stock_match.recipe.portions.length != 0 && (user_recipe_stock_match.recipe[:public] || user_recipe_stock_match.recipe[:user_id] == current_user[:id]) }.compact[0..3]
	end
end
