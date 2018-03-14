class ShoppingList < ApplicationRecord
  belongs_to :user

  has_many :shopping_list_recipes
  has_many :recipes, through: :shopping_list_recipes

  accepts_nested_attributes_for :shopping_list_recipes,
  :reject_if => :all_blank,
  :allow_destroy => true
  accepts_nested_attributes_for :recipes
end
