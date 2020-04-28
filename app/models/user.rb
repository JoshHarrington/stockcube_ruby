include UsersHelper
include StockHelper
include PlannerShoppingListHelper
class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  after_commit :setup_user, on: :create

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  validates_presence_of :name

  has_many :recipes

  has_many :cupboard_users
  has_many :cupboards, through: :cupboard_users

  has_many :user_fav_stocks, dependent: :destroy
  has_many :user_recipe_stock_matches, dependent: :destroy
  has_one :user_setting, dependent: :destroy

	has_many :stock_users
  has_many :stocks, through: :stock_users

  # Favourite recipes of user
  has_many :favourite_recipes # just the 'relationships'
  has_many :favourites, through: :favourite_recipes, source: :recipe # the actual recipes a user favourites

  has_one :planner_shopping_list, dependent: :destroy
  has_many :planner_recipes, dependent: :delete_all
  has_many :planner_shopping_list_portions, dependent: :delete_all
  has_many :combi_planner_shopping_list_portions, dependent: :delete_all

  def update_recipe_matches
    update_recipe_stock_matches_core(nil, self.id, nil)
  end

  def feedback_email(user, issue_details, current_path)
    UserMailer.admin_feedback_notification(user, issue_details, current_path).deliver_now
  end

  def remove_out_of_date_stock
    destroy_old_stock(self)
  end

  def remove_old_planner_portions
    remove_old_planner_portion(self)
  end

  private

    def setup_user
      new_user(self)
    end
end
