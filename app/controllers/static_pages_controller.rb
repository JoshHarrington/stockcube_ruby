class StaticPagesController < ApplicationController
	def home
	end
	def logo
		render action: "logo", layout: "plain"
	end
	def cookie_policy
	end
	def privacy_policy
	end
	def terms_of_use
	end
	def about
	end
end
