class Portion < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient
  has_one :unit, through: :ingredient

  accepts_nested_attributes_for :ingredient,
                                :reject_if => :all_blank
  accepts_nested_attributes_for :unit

  validates :amount, presence: true
	validates_associated :ingredient, presence: true
  validates_numericality_of :amount, on: :create



  def quantity
    Quantity.new(amount, unit.name)
  end
end
