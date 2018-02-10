class Cupboard < ApplicationRecord
	has_many :stocks
	has_many :ingredients, through: :stocks
end
