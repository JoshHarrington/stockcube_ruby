class Types::RecipeType < Types::BaseObject
	field :id, ID, null: false
	field :title, String, null: true
	field :description, String, null: true
	field :cuisine, String, null: true
	field :prep_time, String, null: true
	field :cook_time, String, null: true
	field :yield, String, null: true
	field :public, Boolean, null: false
	field :show_users_name, Boolean, null: true
end
