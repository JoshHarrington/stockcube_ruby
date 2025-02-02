class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :show, :destroy]
  before_action :admin_user,     only: [:destroy, :index]
  before_action :demo_user,      only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_action :correct_user

  include UsersHelper
  include ApplicationHelper

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    if user_signed_in?
      if params[:id]
        redirect_to user_profile_path
      end
      @user = current_user
      @users_recipes = @user.recipes
      @all_recipes = Recipe.all
      @weekdays = {
        'Sunday' => 0,
        'Monday' => 1,
        'Tuesday' => 2,
        'Wednesday' => 3,
        'Thursday' => 4,
        'Friday' => 5,
        'Saturday' => 6
      }
      @weekday_current_id = Time.now.wday
      @weekday_pick = current_user.user_setting.notify_day
    else
      redirect_to new_user_session_path
    end
  end

  def new
    @user = User.new
  end

  def create
    if User.where(email: user_params[:email]).length > 0
      flash[:info] = "A user with that email already exists, please log in"
      redirect_to new_user_session_path(email: user_params[:email]), fallback: root_path
    else
      @user = User.new(user_params)
      if @user.save

        new_user(@user)
        @user.update_attributes(
          activated: true,
          activated_at: Time.zone.now
        )

        if params.has_key?(:user) && params[:user][:cupboard_id].to_s != ''
          @user.send_activation_email_with_cupboard_add
          hashids = Hashids.new(ENV['CUPBOARD_EMAIL_SHARE_ID_SALT'])
          decrypted_cupboard_id = hashids.decode(params[:user][:cupboard_id])
          if CupboardUser.where(cupboard_id: params[:user][:cupboard_id], user_id: @user.id).length == 0
            if decrypted_cupboard_id.class.to_s == 'Array'
              decrypted_cupboard_id.each do |cupboard_id|
                Cupboard.find(cupboard_id).users << @user
              end
            else
              Cupboard.find(decrypted_cupboard_id).users << @user
            end
          else
            flash[:info] = "Looks like you might already have been added to that cupboard"
          end
        end
        flash[:sticky] = %Q[You're all setup! You can start planning meals and building a shopping list straight away]
        log_in @user
        redirect_to planner_path

        # @user.send_activation_email
        # flash[:sticky] = %Q[Thanks for signing up to Stockcubes, we're sending you an email so you can activate your account]
        # redirect_to root_path
      else
        render 'new'
      end
    end
  end

  def google_auth
    user_info = request.env['omniauth.auth']
    if user_info.has_key?("info") && user_info["info"].has_key?("email") && user_info["info"].has_key?("name")
      if User.where(email: user_info["info"]["email"]).length > 0
        g_user = User.where(email: user_info["info"]["email"]).first
        log_in g_user
      else
        password_generate = SecureRandom.base64(14)
        g_user_name = random_name
        if user_info["info"].has_key?("name")
          g_user_name = user_info["info"].has_key?("name").to_s
        end
        g_user = User.create(
          email: params[:email],
          name: g_user_name,
          password: password_generate,
          password_confirmation: password_generate,
          activated: true,
          activated_at: Time.zone.now
        )
        new_user(g_user)
      end

      log_in g_user
      unless user_info["info"].has_key?("name")
        flash[:info] = "Please update your name to finish setting up your account."
        redirect_to user_profile_edit_path(:anchor => "user_name_fix")
      end
      redirect_to planner_path
    else
      flash[:notice] = %Q[That login didn't work. Maybe try it again, or <a href="/signup">sign up</a> for a Stockcubes account]
      redirect_to root_path
    end
  end

  def edit
    if user_signed_in?
      if params[:id]
        redirect_to user_profile_edit_path
      end
      @user = current_user
    else
      redirect_to new_user_session_path
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end



  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password_digest, :cupboard_id)
    end

    ## Before action filters

    # Confirms a logged-in user.
    def logged_in_user
      unless user_signed_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

    def demo_user
      redirect_to(root_url) if current_user && current_user.demo == true
    end

    def correct_user
      if params.has_key?(:id)
        redirect_to(root_url) if current_user.admin == false && current_user != User.find(params[:id])
      end
    end

end
