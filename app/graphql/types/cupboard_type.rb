class Types::CupboardType < Types::BaseObject
	field :id, ID, null: false
	field :users, [Types::UserType], "The users associated to this cupboard", null: false
	field :stocks, [Types::StockType], "The stock in this cupboard", null: true
	field :location, String, null: true
	field :created_at, String, null: false
	field :updated_at, String, null: false
	field :hidden, Boolean, null: true
	field :setup, Boolean, null: true
	field :communal, Boolean, null: true
	field :stocks, [Types::StockType], "The stock in this cupboard", null: false
end
