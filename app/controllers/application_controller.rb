class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include ActionController::Helpers

  before_action :redirect_if_old

  protected

  def redirect_if_old
    if request.host == 'stockcub.es'
      if domain_check('demo') == true
        redirect_to "https://demo.getstockcubes.com"
      else
        redirect_to "https://www.getstockcubes.com"
      end
    end
    # if !(full_domain.to_s.include?('www')) && request.host == 'getstockcubes.com'
    #   redirect_to "https://www.getstockcubes.com", :status => :moved_permanently
    # end
  end

  before_action :run_demo_domain_check


  def domain_check(subdomain_string)
		full_domain = request.host
		if full_domain.to_s.include? '.'
			full_domain = full_domain.split('.')
			subdomain = full_domain[0]
			if subdomain.to_s == subdomain_string.to_s
				return true
			end
		end
	end

  def run_demo_domain_check
    if domain_check('demo') == true
      if logged_in? && current_user && current_user.demo
        log_out
      end
      if User.where(demo: true).length > 0
        demo_user = User.where(demo: true).first
        log_in demo_user
      end
    end
  end
end
