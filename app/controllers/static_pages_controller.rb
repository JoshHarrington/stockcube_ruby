class StaticPagesController < ApplicationController
	def home
    if domain_check('demo') == true
      if logged_in? && current_user && current_user.demo
        log_out
      end
      demo_user = User.where(demo: true).first
      if demo_user
        log_in demo_user
      end
    end
	end
	def about
	end
end