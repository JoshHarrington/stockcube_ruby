module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :recipes, [RecipeType], null: true do
      description "A group of all recipes"
      argument :limit, Integer, required: true
    end

    field :cupboards_from_user_id, [CupboardType], null: true do
      description "A collection of cupboards from a user id"
      argument :user_id, Integer, required: true
    end

    def recipes(limit:)
      Recipe.all.limit(limit)
    end

    def cupboards_from_user_id(user_id:)
      if user_id
        Cupboard.where(id: CupboardUser.where(user_id: user_id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard.setup == true || cu.cupboard.hidden == true }.compact).order(created_at: :desc)
      else
        "no user_id provided"
      end
    end
  end
end
