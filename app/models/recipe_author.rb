class RecipeAuthor < ApplicationRecord
	belongs_to :recipe
	belongs_to :author
end