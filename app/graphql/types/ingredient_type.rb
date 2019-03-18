class Types::IngredientType < Types::BaseObject
	field :id, ID, null: false
	field :stocks, [Types::StockType], "The stocks for this ingredient", null: true
	field :recipes, [Types::RecipeType], "The stocks for this ingredient", null: true
	field :created_at, GraphQL::Types::ISO8601DateTime, null: false
	field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
	field :name, String, null: false
	field :vegan, Boolean, null: false
	field :vegetarian, Boolean, null: false
	field :gluten_free, Boolean, null: false
	field :dairy_free, Boolean, null: false
	field :kosher, Boolean, null: false
end

# has_many :cupboards, through: :stocks
# has_many :shopping_list_portions
# has_many :shopping_lists, through: :shopping_list_portions
# has_one :user_fav_stock