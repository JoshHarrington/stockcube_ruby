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

  def ingredient_out_of_date_notification(user)
    @user = user
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

  def shopping_list_reminder(user)
    @user = user
    mail to: user.email, subject: "Shopping List Reminder"
  end
end
