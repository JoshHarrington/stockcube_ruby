class Recipe < ApplicationRecord

	has_many :portions
  has_many :ingredients, through: :portions
  has_many :units, through: :ingredients

  # Favourited by users
  has_many :favourite_recipes # just the 'relationships'
  has_many :users, through: :favourite_recipes # the actual users favouriting a recipe

  has_many :shopping_list_recipes
  has_many :shopping_lists, through: :shopping_list_recipes

  accepts_nested_attributes_for :portions,
  :reject_if => :all_blank,
  :allow_destroy => true
  accepts_nested_attributes_for :ingredients, :units

  def slug
    title.downcase.gsub(/[\ \,\/]/, ',' => '', ' ' => '_', '/' => '_')
  end

  def to_param
    "#{id}-#{slug}"
  end

  # def self.search(search)
  #   where("lower(title) LIKE :search OR lower(cuisine) LIKE :search", search: "%#{search.downcase}%")
  # end

  # def self.search(search)
  #   searchArray = search.split(%r{\s+})
  #   searchArray.each do |search_item|
  #     where("lower(title) LIKE :search OR lower(cuisine) LIKE :search", search: "%#{search_item.downcase}%")
  #   end
  # end

end

