class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include ApplicationHelper
#     if domain_check('demo') == true
#       if logged_in? && current_user && current_user.demo
#         log_out
#       end
#       if User.where(demo: true).length > 0
#         demo_user = User.where(demo: true).first
#         log_in demo_user
#       end
#     end
end
