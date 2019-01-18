class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      if params.has_key?(:cupboard_add) && params[:cupboard_add].to_s != ''
        flash[:success] = "Account activated and cupboard setup!"
        redirect_to cupboards_path
      else
        flash[:success] = "Account activated!"
        redirect_to user
      end
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end