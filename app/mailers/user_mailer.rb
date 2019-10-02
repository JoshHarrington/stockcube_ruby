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

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end


  def admin_feedback_notification(user, issue_details, current_path)
    @user = user
    @issue_details = issue_details
    @current_path = current_path
    @admin = User.where(admin: true).first
    mail to: @admin.email, subject: "User feedback from site footer form"
  end

end
