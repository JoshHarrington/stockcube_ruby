class ShoppingListPortion < ApplicationRecord
	belongs_to :ingredient
	belongs_to :shopping_list
	has_one :unit, through: :ingredient
end
