class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy, :index]
  before_action :demo_user,      only: [:index, :show, :new, :create, :edit, :update, :destroy]

  def index
    # @users = User.paginate(page: params[:page])
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    @users_recipes = @user.recipes
    @all_recipes = Recipe.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
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
      else
        @user.send_activation_email
      end
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
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

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

    def demo_user
      redirect_to(root_url) if current_user && current_user.demo == true
    end

end
