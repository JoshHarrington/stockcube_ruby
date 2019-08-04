class DashboardController < ApplicationController
	def dash
		@recipes = Recipe.first(8)
	end
end