class UserMailer < ApplicationMailer
	def admin_feedback_notification(user, issue_details, current_path)
		return unless User.where(admin: true).length > 0
		@user = user
		@current_path = current_path
		@issue_details = issue_details
		mail(
			to: User.where(admin: true).first.email,
			cc: User.where(admin:true).length > 1 ? User.where(admin:true)[1..-1].map(&:email) : nil,
			subject: "User feedback form submitted"
		)
	end

end
