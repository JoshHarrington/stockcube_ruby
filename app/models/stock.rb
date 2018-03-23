class Stock < ApplicationRecord
	belongs_to :cupboard
	belongs_to :ingredient
	has_one :unit, through: :ingredient

	accepts_nested_attributes_for :ingredient,
	:reject_if => :all_blank
	accepts_nested_attributes_for :unit

	validates :amount, presence: true
	validates_numericality_of :amount, on: :create
	validates :use_by_date, presence: true
end
