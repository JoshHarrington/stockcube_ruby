class DashboardController < ApplicationController
	def dash
		# @recipes = Recipe.first(8)
		@recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
	end
end