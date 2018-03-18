class Cupboard < ApplicationRecord
	has_many :stocks
	has_many :ingredients, through: :stocks

	belongs_to :user

	accepts_nested_attributes_for :stocks,
	:reject_if => :all_blank,
	:allow_destroy => true
	accepts_nested_attributes_for :ingredients
end
