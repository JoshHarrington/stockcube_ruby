class StockUser < ApplicationRecord
	belongs_to :stock
	belongs_to :user, optional: true
end
