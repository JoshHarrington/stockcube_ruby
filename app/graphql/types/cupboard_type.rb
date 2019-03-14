class Types::CupboardType < Types::BaseObject
	field :id, ID, null: false
	field :user_id, ID, null: true
	field :location, String, null: true
	field :created_at, String, null: false
	field :updated_at, String, null: false
	field :hidden, Boolean, null: true
	field :setup, Boolean, null: true
	field :communal, Boolean, null: true
end
