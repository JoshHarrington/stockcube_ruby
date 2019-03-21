class Types::UserFavStockType < Types::BaseObject
	field :id, ID, null: false
	field :ingredient, Types::IngredientType, "The ingredient in this User Fav Stock", null: false
	field :unit, Types::UnitType, "The unit for this User Fav Stock", null: false
	field :user, Types::UserType, "The user this user fav stock belongs to", null: false
	field :stock_amount, Integer, null: true
	field :standard_use_by_limit, Integer, null: true
	field :created_at, GraphQL::Types::ISO8601DateTime, null: false
	field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end
