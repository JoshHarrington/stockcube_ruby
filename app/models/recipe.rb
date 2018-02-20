require 'uri'

class Recipe < ApplicationRecord
	has_many :portions
	has_many :ingredients, through: :portions
	has_many :favourites
	has_many :users, through: :favourites
end

