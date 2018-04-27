class Recipe < ApplicationRecord
	has_many :portions
	has_many :ingredients, through: :portions

  # Favourited by users
  has_many :favourite_recipes # just the 'relationships'
  has_many :users, through: :favourite_recipes # the actual users favouriting a recipe

  has_many :shopping_list_recipes
  has_many :shopping_lists, through: :shopping_list_recipes

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

  # ingredients_list = ""
  # self.ingredients.each do |ingredient|
  #   ingredients_list += ingredient.name.to_s + " "
  # end
  # ingredients_list = ingredients_list.strip



  def self.search(search)
    where("lower(title) LIKE :search OR lower(description) LIKE :search OR lower(cuisine) LIKE :search", search: "%#{search.downcase}%")
    # where("lower(description) LIKE ?", "%#{search.downcase}%")
    # where("lower(cuisine) LIKE ?", "%#{search.downcase}%")
    # where("lower(ingredients_list) LIKE ?", "%#{search.downcase}%")
  end
end

