class Types::UserType < Types::BaseObject
	field :id, ID, null: true
	field :name, String, null: true
	field :email, String, null: true
	field :created_at, GraphQL::Types::ISO8601DateTime, null: true
	field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
	field :password_digest, String, null: true
	field :remember_digest, String, null: true
	field :admin, Boolean, null: true
	field :activation_digest, String, null: true
	field :activated, Boolean, null: true
	field :activated_at, GraphQL::Types::ISO8601DateTime, null: true
	field :reset_digest, String, null: true
	field :reset_sent_at, GraphQL::Types::ISO8601DateTime, null: true
	field :demo, Boolean, null: true
end
