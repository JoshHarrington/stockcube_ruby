class Ingredient < ApplicationRecord
	belongs_to :unit, optional: true
	has_many :portions, dependent: :delete_all
	has_many :recipes, through: :portions
	has_many :stocks, dependent: :delete_all
	has_many :cupboards, through: :stocks
	has_many :planner_shopping_list_portions, dependent: :delete_all
	has_many :combi_planner_shopping_list_portions, dependent: :delete_all
	has_one :user_fav_stock, dependent: :delete
	has_many :default_ingredient_sizes, dependent: :delete_all

	validates :name, presence: true, allow_blank: false
	validates_uniqueness_of :name, :case_sensitive => false

	searchkick

  def search_data
    {name: name}
  end

end
