require 'uri'

class Meal < ApplicationRecord
	has_many :portions
	has_many :ingredients, through: :portions
end

def description_unescape
	description = @meal.description
	description.gsub!(/\n/, '<br />').html_safe
end
