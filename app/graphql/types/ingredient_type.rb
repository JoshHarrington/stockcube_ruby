class Types::IngredientType < Types::BaseObject
	field :id, ID, null: false
	field :stocks, [Types::StockType], "The stocks for this ingredient", null: true
	field :created_at, GraphQL::Types::ISO8601DateTime, null: false
	field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
	field :name, String, null: false
	field :vegan, Boolean, null: false
	field :vegetarian, Boolean, null: false
	field :gluten_free, Boolean, null: false
	field :dairy_free, Boolean, null: false
	field :kosher, Boolean, null: false
end

# field :portions, [Types::PortionType], "The portions for this ingredient", null: true
# field :recipes, [Types::RecipeType], "The stocks for this ingredient", null: true