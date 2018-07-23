class Cupboard < ApplicationRecord
	has_many :stocks
	has_many :ingredients, through: :stocks

	has_many :cupboard_users
	has_many :users, through: :cupboard_users

	accepts_nested_attributes_for :stocks,
					:reject_if => :all_blank,
					:allow_destroy => true
	accepts_nested_attributes_for :ingredients

	validates :location, presence: true
end
