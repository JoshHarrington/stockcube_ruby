class Author < ApplicationRecord
	has_many :recipe_authors, dependent: :delete_all
  has_many :recipes, through: :recipe_authors
end
