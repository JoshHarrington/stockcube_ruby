class CupboardUser < ApplicationRecord
	belongs_to :cupboard
	belongs_to :user
end
