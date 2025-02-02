class Unit < ApplicationRecord
  has_many :ingredients, dependent: :nullify
  has_many :portions, dependent: :nullify
  has_one :stock, dependent: :nullify
  has_one :user_fav_stock, dependent: :nullify
  has_many :default_ingredient_sizes, dependent: :delete_all
end
