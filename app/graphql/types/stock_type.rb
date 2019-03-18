class Types::StockType < Types::BaseObject
	field :id, ID, null: false
	field :cupboard, Types::CupboardType, "The cupboard this stock is within", null: false
	field :users, [Types::UserType], "The user this stock belongs to", null: false
	field :unit, Types::UnitType, "The unit for this stock", null: false
	field :use_by_date, Types::Date, null: false
	field :amount, Float, null: false
	field :created_at, GraphQL::Types::ISO8601DateTime, null: false
	field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
	field :hidden, Boolean, null: false
	field :always_available, Boolean, null: false
end
