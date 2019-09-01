class Portion < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient
  has_one :unit

  validates :amount, presence: true
  validates_numericality_of :amount, on: :create
	validates :ingredient_id, presence: true
	validates :unit_id, presence: true



  def quantity
    Quantity.new(amount, unit.name)
  end
end
