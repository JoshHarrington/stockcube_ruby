require 'uri'

class Meal < ApplicationRecord
	has_many :portions
	has_many :ingredients, through: :portions
end

def description_unescape
	description = @meal.description
	regex_replace = '<br /><br />\1<br />'

	description = URI.unescape(description)
	description.gsub!(/(\[\"\s*YIELDS*\:\ )|(\"\])/, '')
	description.gsub!(/([A-Z]+\s*[A-Z]+\s*[A-Z]*[0-9]*:\s)/, regex_replace).titleize.html_safe
end
