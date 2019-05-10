module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :recipes, [RecipeType], null: true do
      description "A group of all recipes"
      argument :limit, Integer, required: false
    end

    field :user_fav_stock, [UserFavStockType], null: true do
      description "A group of user favourite stock - aka quick add stock"
      argument :user_id, Integer, required: true
    end

    field :cupboards_from_user_id, [CupboardType], null: true do
      description "A collection of cupboards from a user id"
      argument :user_id, Integer, required: true
      argument :limit, Integer, required: false
    end

    def recipes(limit: 4)
      Recipe.all.limit(limit)
    end

    def user_fav_stock(user_id: nil)
      UserFavStock.where(user_id: user_id)
    end

    def cupboards_from_user_id(user_id: nil, limit: 4)
      Cupboard.where(id: CupboardUser.where(user_id: user_id, accepted: true).map{|cu| cu.cupboard.id unless cu.cupboard.setup == true || cu.cupboard.hidden == true }.compact).order(created_at: :desc).limit(limit)
    end
  end
end
