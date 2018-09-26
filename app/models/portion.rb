class Portion < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient
  has_one :unit, through: :ingredient

  accepts_nested_attributes_for :ingredient,
                                :reject_if => :all_blank
  accepts_nested_attributes_for :unit

  validates :amount, presence: true
  validates_numericality_of :amount, on: :create
	validates :ingredient_id, presence: true
	validates :unit_number, presence: true



  def quantity
    Quantity.new(amount, unit.name)
  end
end
