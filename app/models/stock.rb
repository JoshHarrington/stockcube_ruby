class Stock < ApplicationRecord
	belongs_to :cupboard
	belongs_to :ingredient
	belongs_to :unit
end
