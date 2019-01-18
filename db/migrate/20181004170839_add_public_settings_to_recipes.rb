class AddPublicSettingsToRecipes < ActiveRecord::Migration[5.1]
  def change
    add_column :recipes, :user_id, :integer
    add_column :recipes, :public, :boolean, null: false, default: true
    add_column :recipes, :show_users_name, :boolean, null: false, default: true
  end
end
