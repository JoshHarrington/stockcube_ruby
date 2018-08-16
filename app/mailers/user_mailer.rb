class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end


  def account_activation_with_cupboard_sharing(user)
    @user = user
    mail to: user.email, subject: "Account activation and joining a cupboard"
  end

  def ingredient_out_of_date_notification(user, stock_going_off)
    @user = user
    @stock_going_off = stock_going_off.group_by(&:cupboard_id)
    mail to: user.email, subject: "Ingredients going out of date this week"
  end

  def sign_in_activity(user)
    hashids = Hashids.new(ENV['USER_ID_SALT'])
    @encoded_user_id = hashids.encode(user.id)
    mail to: user.email, subject: "Sign in alert for your Stockcubes account"
  end

  def admin_notify_for_sign_in_error(user)
    admin = User.where(admin: true).first
    @user = user
    mail to: admin.email, subject: "Stockcubes: Notification for sign in error"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end

  def shopping_list_reminder(user)
    @user = user
    mail to: user.email, subject: "Shopping List Reminder"
  end
end
