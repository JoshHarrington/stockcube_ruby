class Portion < ApplicationRecord
  belongs_to :recipe, inverse_of: :portions, autosave: true, dependent: :destroy
  validates :recipe, presence: true
  belongs_to :ingredient, inverse_of: :portions

  accepts_nested_attributes_for :ingredient,
                                :reject_if => :all_blank
end
