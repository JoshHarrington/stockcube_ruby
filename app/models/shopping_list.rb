class ShoppingList < ApplicationRecord
  belongs_to :user
  has_many :recipes
  
  # Favourite recipes of user
  has_many :shopping_list_recipes # just the 'relationships'
  has_many :shopping_list_add, through: :shopping_list_recipes, source: :recipe # the actual recipes a shopping_list addition
end
