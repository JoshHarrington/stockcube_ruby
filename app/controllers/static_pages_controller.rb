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
end
