require 'uri'

class Meal < ApplicationRecord
	has_many :portions
	has_many :ingredients, through: :portions
end

def description_unescape
	description = @meal.description
	description = URI.unescape(description)
	description.gsub!(/(\[\"YIELDS\:\ )|(\"\])/, '')
	regex_replace = "\n"
	regex_replace += "\n"
	regex_replace += '\1'
	regex_replace += "\n"
	description.gsub!(/([A-Z]+\s*[A-Z]+\s*[A-Z]*:\s)/, regex_replace)
end