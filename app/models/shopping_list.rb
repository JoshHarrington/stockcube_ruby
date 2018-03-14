class ShoppingList < ApplicationRecord
  belongs_to :user
  has_many :recipes

  accepts_nested_attributes_for :recipes,
  :reject_if => :all_blank,
  :allow_destroy => true
end
