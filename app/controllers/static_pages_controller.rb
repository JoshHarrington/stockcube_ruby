class StaticPagesController < ApplicationController
	def home
	end
	def logo
		unless user_signed_in? && current_user.admin
			redirect_to root_path
		end
	end
	def about
	end
end
