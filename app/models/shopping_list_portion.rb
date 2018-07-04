class ShoppingListPortion < ApplicationRecord
	belongs_to :ingredient
	belongs_to :shopping_list
	has_one :unit, through: :ingredient

	attr_accessor :ingredient_id, :shopping_list_id, :unit_number, :recipe_number, :portion_amount, :stock_amount, :in_cupboard, :percent_in_cupboard, :checked, :enough_in_cupboard, :plenty_in_cupboard

	def quantity
    Quantity.new(amount, unit.name)
  end
end
