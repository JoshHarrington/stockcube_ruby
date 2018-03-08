class Recipe < ApplicationRecord
	has_many :portions
	has_many :ingredients, through: :portions

  # Favourited by users
  has_many :favourite_recipes # just the 'relationships'
  has_many :users, through: :favourite_recipes # the actual users favouriting a recipe

  accepts_nested_attributes_for :portions,
           :reject_if => :all_blank,
           :allow_destroy => true
  accepts_nested_attributes_for :ingredients

  def self.search(search)
    where("lower(title) LIKE ?", "%#{search.downcase}%")
    where("lower(description) LIKE ?", "%#{search.downcase}%")
  end
end

