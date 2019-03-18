class Types::UnitType < Types::BaseObject
	field :id, ID, null: false
	field :unit_number, Integer, null: true
	field :name, String, null: true
	field :short_name, String, null: true
	field :unit_type, String, null: true
	field :metric_ratio, Float, null: true
	field :created_at, GraphQL::Types::ISO8601DateTime, null: true
	field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
end
