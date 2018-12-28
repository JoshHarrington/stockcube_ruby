class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :show, :destroy]
  before_action :admin_user,     only: [:destroy, :index]
  before_action :demo_user,      only: [:index, :show, :new, :create, :edit, :update, :destroy]

  include StockHelper
  include UsersHelper

  def index
    # @users = User.paginate(page: params[:page])
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    if current_user && logged_in?
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
      redirect_to login_path
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save

      new_user(@user)
      @user.update_attributes(
        activated: true,
        activated_at: Time.zone.now
      )

      if params.has_key?(:user) && params[:user][:cupboard_id].to_s != ''
        @user.send_activation_email_with_cupboard_add
        hashids = Hashids.new(ENV['CUPBOARD_ID_SALT'])
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
      flash[:info] = "You're all setup!"
      log_in @user
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    if current_user && logged_in?
      if params[:id]
        redirect_to user_profile_edit_path
      end
      @user = current_user
    else
      redirect_to login_path
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

  def notifications
    if params.has_key?(:notifications) && params.has_key?(:weekday)
      user_notification_status = current_user.user_setting.notify
      param_notification_status = params[:notifications].to_unsafe_h.keys[0].to_s

      user_weekday_setting = current_user.user_setting.notify_day
      param_weekday_setting = params[:weekday].to_unsafe_h.keys[0].to_i

      weekday_range = [*0..6]
      if weekday_range.include?(param_weekday_setting)
        if param_notification_status.to_s != user_notification_status || user_weekday_setting.to_s != param_weekday_setting.to_s
          current_user.user_setting.update_attributes(
            notify: param_notification_status,
            notify_day: param_weekday_setting
          )
        end
      end
    end
  end

  def new_from_g_sign_in
    if params.has_key?(:email) && params[:email].to_s != '' && params[:email].to_s != 'null'
      if User.where(email: params[:email]).length > 0
        g_user = User.where(email: params[:email]).first
        log_in g_user
        redirect_to root_url
      else
        password_generate = SecureRandom.base64(14)
        g_user_name = '21st Century Human'
        if params.has_key?(:name) && params[:name].to_s != ''
          g_user_name = params[:name].to_s
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

        log_in g_user
        if params.has_key?(:name) && params[:name].to_s != ''
          redirect_to root_url
        else
          flash[:info] = "Please update your name to finish setting up your account."
          redirect_to user_profile_edit_path(:anchor => "user_name_fix")
        end
      end
    else
      flash[:notice] = %Q[That login didn't work. Maybe try it again, or <a href="/signup">sign up</a> for a Stockcubes account]
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation, :cupboard_id)
    end

    ## Before action filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
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

end
