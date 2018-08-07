class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include ActionController::Helpers
  before_action :run_demo_domain_check
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
