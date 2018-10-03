class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :show, :destroy]
  before_action :correct_user,   only: [:edit, :update, :show]
  before_action :admin_user,     only: [:destroy, :index]
  before_action :demo_user,      only: [:index, :show, :new, :create, :edit, :update, :destroy]

  include StockHelper

  def index
    # @users = User.paginate(page: params[:page])
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
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
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save

      ### setup user with some fav stock for quick add
      @tomatoe_id = Ingredient.where(name: "Tomatoes").first.id
      @egg_id = Ingredient.where(name: "Egg").first.id
      @bread_id = Ingredient.where(name: "Bread (White)").first.id  ## need to add (to production)
      @milk_id = Ingredient.where(name: "Milk").first.id
      @onion_id = Ingredient.where(name: "Onion").first.id
      @cheese_id = Ingredient.where(name: "Cheese (Cheddar)").first.id

      @each_unit_id = Unit.where(name: "Each").first.id
      @loaf_unit_id = Unit.where(name: "Loaf").first.id 	## need to add (to production)
      @pint_unit_id = Unit.where(name: "Pint").first.id
      @gram_unit_id = Unit.where(name: "Gram").first.id

      UserFavStock.create(
        ingredient_id: @tomatoe_id,
        stock_amount: 4,
        unit_id: @each_unit_id,
        user_id: @user.id,
        standard_use_by_limit: 5
      )
      UserFavStock.create(
        ingredient_id: @egg_id,
        stock_amount: 6,
        unit_id: @each_unit_id,
        user_id: @user.id,
        standard_use_by_limit: 9
      )
      UserFavStock.create(
        ingredient_id: @bread_id,
        stock_amount: 1,
        unit_id: @loaf_unit_id,
        user_id: @user.id,
        standard_use_by_limit: 4
      )
      UserFavStock.create(
        ingredient_id: @milk_id,
        stock_amount: 1,
        unit_id: @pint_unit_id,
        user_id: @user.id,
        standard_use_by_limit: 8
      )
      UserFavStock.create(
        ingredient_id: @onion_id,
        stock_amount: 3,
        unit_id: @each_unit_id,
        user_id: @user.id,
        standard_use_by_limit: 14
      )
      UserFavStock.create(
        ingredient_id: @cheese_id,
        stock_amount: 350,
        unit_id: @gram_unit_id,
        user_id: @user.id,
        standard_use_by_limit: 28
      )


      ### setup user with default settings
      UserSetting.create(
        user_id: @user.id
      )

      ### setup user with default cupboard
      new_cupboard = Cupboard.create(location: "Kitchen")
      CupboardUser.create(
        cupboard_id: new_cupboard.id,
        user_id: @user.id,
        owner: true,
        accepted: true
      )

      water_id = Ingredient.where(name: "Water").map(&:id).first
      liter_id = Unit.where(name: "Liter").map(&:id).first
      Stock.create(
        hidden: false,
        always_available: true,
        ingredient_id: water_id,
        cupboard_id: new_cupboard[:id],
        unit_id: liter_id,
        amount: 9223372036854775807,
        use_by_date: Date.current + 100.years
      )

      recipe_stock_matches_update(@user.id)

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
      flash[:info] = "Check your email to activate your account."
      log_in @user
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
        ### setup user with some fav stock for quick add
        @tomatoe_id = Ingredient.where(name: "Tomatoes").first.id
        @egg_id = Ingredient.where(name: "Egg").first.id
        @bread_id = Ingredient.where(name: "Bread (White)").first.id  ## need to add (to production)
        @milk_id = Ingredient.where(name: "Milk").first.id
        @onion_id = Ingredient.where(name: "Onion").first.id
        @cheese_id = Ingredient.where(name: "Cheese (Cheddar)").first.id

        @each_unit_id = Unit.where(name: "Each").first.id
        @loaf_unit_id = Unit.where(name: "Loaf").first.id 	## need to add (to production)
        @pint_unit_id = Unit.where(name: "Pint").first.id
        @gram_unit_id = Unit.where(name: "Gram").first.id

        UserFavStock.create(
          ingredient_id: @tomatoe_id,
          stock_amount: 4,
          unit_id: @each_unit_id,
          user_id: g_user.id,
          standard_use_by_limit: 5
        )
        UserFavStock.create(
          ingredient_id: @egg_id,
          stock_amount: 6,
          unit_id: @each_unit_id,
          user_id: g_user.id,
          standard_use_by_limit: 9
        )
        UserFavStock.create(
          ingredient_id: @bread_id,
          stock_amount: 1,
          unit_id: @loaf_unit_id,
          user_id: g_user.id,
          standard_use_by_limit: 4
        )
        UserFavStock.create(
          ingredient_id: @milk_id,
          stock_amount: 1,
          unit_id: @pint_unit_id,
          user_id: g_user.id,
          standard_use_by_limit: 8
        )
        UserFavStock.create(
          ingredient_id: @onion_id,
          stock_amount: 3,
          unit_id: @each_unit_id,
          user_id: g_user.id,
          standard_use_by_limit: 14
        )
        UserFavStock.create(
          ingredient_id: @cheese_id,
          stock_amount: 350,
          unit_id: @gram_unit_id,
          user_id: g_user.id,
          standard_use_by_limit: 28
        )


        ### setup user with default settings
        UserSetting.create(
          user_id: g_user.id
        )

        ### setup user with default cupboard
        new_cupboard = Cupboard.create(location: "Fridge (Default cupboard)")
        CupboardUser.create(
          cupboard_id: new_cupboard.id,
          user_id: g_user.id,
          owner: true,
          accepted: true
        )

        water_id = Ingredient.where(name: "Water").map(&:id).first
        liter_id = Unit.where(name: "Liter").map(&:id).first
        Stock.create(
          hidden: false,
          always_available: true,
          ingredient_id: water_id,
          cupboard_id: new_cupboard[:id],
          unit_id: liter_id,
          amount: 9223372036854775807,
          use_by_date: Date.current + 100.years
        )

        recipe_stock_matches_update(@user.id)

        log_in g_user
        if params.has_key?(:name) && params[:name].to_s != ''
          redirect_to root_url
        else
          flash[:info] = "Please update your name to finish setting up your account."
          redirect_to edit_user_path(:id => g_user.id, :anchor => "user_name_fix")
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
