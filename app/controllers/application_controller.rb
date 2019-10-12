class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ActionController::Helpers

  before_action :configure_permitted_parameters, if:  :devise_controller?
  before_action :redirect_if_old
  before_action :run_demo_domain_check

  protected

    def redirect_if_old
      if request.host == 'stockcub.es' || request.host == 'www.stockcub.es'
        redirect_to 'https://www.getstockcubes.com', :status => :moved_permanently
      end
      if request.host == 'demo.stockcub.es'
        redirect_to 'https://demo.getstockcubes.com', :status => :moved_permanently
      end
      if request.host == 'getstockcubes.com'
        redirect_to 'https://www.getstockcubes.com', :status => :moved_permanently
      end
    end


    def run_demo_domain_check
      if request.host == 'demo.getstockcubes.com'
        if user_signed_in? && current_user.demo
          log_out
        end
        if User.where(demo: true).length > 0
          demo_user = User.where(demo: true).first
          log_in demo_user
        end
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    end
end
