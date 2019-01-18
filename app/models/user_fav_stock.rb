class UserFavStock < ApplicationRecord
	belongs_to :unit
	belongs_to :user
	belongs_to :ingredient
end
