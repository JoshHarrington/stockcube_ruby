module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :recipes, [RecipeType], null: true do
      description "A group of all recipes"
    end

    def recipes
      Recipe.all.limit(10)
    end
  end
end
