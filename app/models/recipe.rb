class Recipe < ApplicationRecord
  has_many :portions
  has_many :ingredients, through: :portions

  belongs_to :user

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

  def slug
    title.downcase.gsub(/[\ \,\/]/, ',' => '', ' ' => '_', '/' => '_')
  end

  def to_param
    "#{id}-#{slug}"
  end

  searchkick

  def search_data
    {
      title: title,
      cuisine: cuisine,
      description: description,
      ingredient_names: ingredients.map(&:name)
    }
  end
end

