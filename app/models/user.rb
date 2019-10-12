class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

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

end
