require 'uri'

class Recipe < ApplicationRecord
	has_many :portions
	has_many :ingredients, through: :portions
end

def description_unescape
	description = @recipe.description
	description.gsub!(/\n/, '<br />').html_safe
end
