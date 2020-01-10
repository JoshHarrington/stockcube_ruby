class UsersController < ApplicationController
	before_action :authenticate_user!
	before_action :admin_user, only: [:index]

	require 'will_paginate/array'

	def index
		users = User.all.order("created_at ASC")
		if params.has_key?(:confirmed)
			if params[:confirmed].to_s == 'true'
				users = users.map{|u| u if u.confirmed? == true}.compact
			elsif params[:confirmed].to_s == 'false'
				users = users.map{|u| u if u.confirmed? == false}.compact
			end
		end
		@users = users.paginate(:page => params[:page], :per_page => 10)
	end

	def profile
		if current_user.user_setting == nil
			UserSetting.create(user_id: current_user.id)
			render :profile
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
	end

	def notifications
    if params.has_key?(:notifications) && params.has_key?(:weekday)
      user_notification_status = current_user.user_setting.notify
      param_notification_status = params[:notifications].to_unsafe_h.keys[0]

      user_weekday_setting = current_user.user_setting.notify_day.to_i
      param_weekday_setting = params[:weekday].to_unsafe_h.keys[0].to_i

      weekday_range = [*0..6]
      if weekday_range.include?(param_weekday_setting)
        current_user.user_setting.update_attributes(
          notify_day: param_weekday_setting
        )
        current_user.user_setting.update_attributes(
          notify: param_notification_status
        )
      end
    end
  end


	protected
		# Confirms an admin user.
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end
end
