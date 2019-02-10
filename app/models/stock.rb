class Stock < ApplicationRecord
	belongs_to :cupboard
	belongs_to :ingredient
	belongs_to :unit
	has_many :stock_users
	has_many :users, through: :stock_users

	accepts_nested_attributes_for :ingredient,
																:reject_if => :all_blank
	accepts_nested_attributes_for :unit

	validates :ingredient_id, presence: {message: "Make sure you select an ingredient"}
	validates :amount, presence: {message: "Amount needed - can't be blank"}
	validates_numericality_of :amount, on: :create
	validates :use_by_date, presence: {message: "Make sure you select a date"}
	validates :unit_id, presence: {message: "Make sure you select a unit"}


	def quantity
    Quantity.new(amount, unit.name)
  end
end
