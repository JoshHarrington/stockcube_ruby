class Portion < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient
  has_many :units

  accepts_nested_attributes_for :ingredient,
                                :reject_if => :all_blank
end
