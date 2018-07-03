class ShoppingListPortion < ApplicationRecord
	belongs_to :ingredient
	belongs_to :shopping_list
	has_one :unit, through: :ingredient

	def quantity
    Quantity.new(amount, unit.name)
  end
end
