class Recipe < ApplicationRecord
	has_many :portions
	has_many :ingredients, through: :portions

  belongs_to :users
  
  has_reputation :favourites, source: :user, aggregated_by: :sum


  accepts_nested_attributes_for :portions,
           :reject_if => :all_blank,
           :allow_destroy => true
  accepts_nested_attributes_for :ingredients
end

