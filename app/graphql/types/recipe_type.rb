module Types
  class RecipeType < Types::BaseObject
		field :id, Integer, null: false
		field :title, String, null: false
		field :description, String, null: false
		field :cuisine, String, null: false
		field :prep_time, String, null: false
		field :cook_time, String, null: false
		field :yield, String, null: false
		field :public, Boolean, null: false
		field :show_users_name, Boolean, null: false
  end
end
