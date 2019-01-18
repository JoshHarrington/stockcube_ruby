class AddNotifyDayToUserSetting < ActiveRecord::Migration[5.1]
  def change
    add_column :user_settings, :notify_day, :integer, default: 0
  end
end
