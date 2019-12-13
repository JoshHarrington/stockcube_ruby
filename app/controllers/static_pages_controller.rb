class StaticPagesController < ApplicationController
	def home
	end
	def logo
		render action: "logo", layout: "plain"
	end
	def about
	end
end
