class Ingredient < ApplicationRecord
	belongs_to :unit, optional: true
	has_many :portions, dependent: :delete_all
	has_many :recipes, through: :portions
	has_many :stocks, dependent: :delete_all
	has_many :cupboards, through: :stocks
	has_many :shopping_list_portions, dependent: :delete_all
	has_many :shopping_lists, through: :shopping_list_portions
	has_one :user_fav_stock

	searchkick

  def search_data
    {name: name}
  end

end
