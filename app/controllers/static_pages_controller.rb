class StaticPagesController < ApplicationController
	def home
    if domain_check('demo') == true
      demo_user = User.where(demo: true).first
      if demo_user
        log_in demo_user
      end
    end
	end
	def about
	end
end