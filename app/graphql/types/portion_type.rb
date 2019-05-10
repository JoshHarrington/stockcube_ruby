class Types::PortionType < Types::BaseObject
	field :id, ID, null: false
	field :recipe, Types::RecipeType, "The recipe this portion is within", null: false
	field :unit, Types::UnitType, "The unit for this stock", null: false
	field :use_by_date, Types::Date, null: false
	field :amount, Float, null: false
	field :created_at, GraphQL::Types::ISO8601DateTime, null: false
	field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
	field :hidden, Boolean, null: false
	field :always_available, Boolean, null: false
end
