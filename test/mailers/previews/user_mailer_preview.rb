# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def confirmation_instructions
    DeviseCustomMailer.confirmation_instructions(User.first, {})
  end

  def email_changed
    DeviseCustomMailer.email_changed(User.first, {})
  end

  def password_change
    DeviseCustomMailer.password_change(User.first, {})
  end

  def reset_password_instructions
    DeviseCustomMailer.reset_password_instructions(User.first, {})
  end

  # def unlock_instructions
  #   DeviseCustomMailer.unlock_instructions(User.first, {})
  # end

end
