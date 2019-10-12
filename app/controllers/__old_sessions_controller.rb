require 'omniauth'
require 'omniauth-google-oauth2'

class SessionsController < ApplicationController
  before_action :demo_restrict,      only: [:new, :create, :destroy]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        if user.cupboards.length > 0
          redirect_to cupboards_path
        else
          redirect_back_or recipes_path
        end
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def demo_logout
    log_out if user_signed_in?
    redirect_to new_user_registration_path
  end

  def destroy
    log_out if user_signed_in?
    redirect_to root_url
  end

  private

    def demo_restrict
      if current_user && current_user.demo == true
        redirect_to(root_url)
      end
    end
end