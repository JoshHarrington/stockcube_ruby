class Stock < ApplicationRecord
	belongs_to :cupboard
	belongs_to :ingredient

	accepts_nested_attributes_for :ingredient,
				:reject_if => :all_blank
end
