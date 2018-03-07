class Stock < ApplicationRecord
	belongs_to :cupboard
	belongs_to :ingredient
end
