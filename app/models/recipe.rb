class Recipe < ApplicationRecord
  has_many :portions, dependent: :delete_all
  has_many :ingredients, through: :portions
  has_many :planner_recipes, dependent: :delete_all
  has_many :recipe_steps, dependent: :delete_all
  has_many :recipe_authors, dependent: :delete_all
  has_many :authors, through: :recipe_authors


  belongs_to :user, optional: true

  # Favourited by users
  has_many :favourite_recipes # just the 'relationships'
  has_many :users, through: :favourite_recipes # the actual users favouriting a recipe

  has_many :shopping_list_recipes
  has_many :shopping_lists, through: :shopping_list_recipes

  has_many :user_recipe_stock_matches

  accepts_nested_attributes_for :portions,
  :reject_if => :all_blank,
  :allow_destroy => true
  accepts_nested_attributes_for :ingredients

  validates :title, presence: true

  def slug
    title.downcase.gsub(/[\ \,\/]/, ',' => '', ' ' => '_', '/' => '_')
  end

  def to_param
    "#{id}-#{slug}"
  end

  searchkick

  def should_index?
    live
  end

  def search_data
    {
      title: title,
      cuisine: cuisine,
      description: description,
      ingredient_names: ingredients.map(&:name)
    }
  end
end

