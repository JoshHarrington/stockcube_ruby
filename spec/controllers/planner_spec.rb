require 'rails_helper'
require 'json'

describe PlannerController do

  it "planner should redirect to sign in if not logged in" do
    get :index
    expect(response).to redirect_to(new_user_session_path)
  end

end

describe PlannerController do

  let!(:user) { create(:user) }
  before do
    user.confirm
    sign_in(user)
  end

  it "should get planner" do
    get :index
    expect(response).to be_success
  end

  let(:headers) {{
    "ACCEPT": "application/json"
  }}

  let(:recipe_id_hash){Hashids.new(ENV['RECIPE_ID_SALT'])}

  context "with valid parameters" do
    let!(:unit) { create(:unit)}
    let!(:ingredient) { create(
      :ingredient
    )}
    let!(:recipe) { create(:recipe)}
    let!(:portion) {
      create(
        :portion,
        ingredient_id: ingredient.id,
        recipe_id: recipe.id,
        unit_id: unit.id
      )
    }
    let(:valid_recipe_id) {recipe.id}
    let(:valid_params){{
      recipe_id: recipe_id_hash.encode(valid_recipe_id)
    }}

    it "should let user add recipe to planner" do
      request.headers.merge! headers
      post :recipe_add_to_planner, params: valid_params

      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:ok)
      expect(PlannerRecipe.last[:recipe_id]).to eq valid_recipe_id
    end
  end

  context "with invalid parameters" do
    let!(:recipe) { create(:recipe)}
    let(:invalid_recipe_id) {recipe.id.to_i + 1}
    let(:invalid_params) {{
      recipe_id: invalid_recipe_id
    }}

    it "should not let user add recipe to planner" do
      request.headers.merge! headers
      post :recipe_add_to_planner, params: invalid_params

      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:not_found)
      expect(PlannerRecipe.where(recipe_id: recipe.id.to_i + 1).length).to eq 0
    end
  end

  context "with a mix of recipe portions" do
    it "should show the correct shopping list portions" do
      units = create_list(:unit, 2)
      ingredients = create_list(:ingredient, 2)
      recipes = create_list(:recipe, 2)
      portion_1 = create(:portion, ingredient_id: ingredients.first.id, recipe_id: recipes.first.id, unit_id: units.first.id)
      portion_2 = create(:portion, ingredient_id: ingredients.first.id, recipe_id: recipes.last.id, unit_id: units.first.id)
      portion_3 = create(:portion, ingredient_id: ingredients.last.id, recipe_id: recipes.last.id, unit_id: units.last.id)

      planner_recipe_1 = create(
        :planner_recipe,
        recipe_id: recipes.first.id,
        planner_shopping_list_id: user.planner_shopping_list.id,
        user_id: user.id,
        date: Date.current + 1.day
      )
      planner_recipe_2 = create(
        :planner_recipe,
        recipe_id: recipes.last.id,
        planner_shopping_list_id: user.planner_shopping_list.id,
        user_id: user.id,
        date: Date.current + 2.day
      )

      update_planner_shopping_list_portions(user)

      fetched_shopping_list_portions = shopping_list_portions(nil, user)
      newly_processed_shopping_list_portions = processed_shopping_list_portions(fetched_shopping_list_portions)

      expect(fetched_shopping_list_portions.count{|p|p[:checked]}).to eq 0
      expect(fetched_shopping_list_portions.count).to eq 2

      combi_planner_portions = newly_processed_shopping_list_portions.select{|p|p[:type] == "combi_portion"}
      expect(combi_planner_portions.length).to eq 1
      expect(combi_planner_portions.first[:description]).to eq "2 Unit 1s Ingredient 1"

      indi_planner_portions = newly_processed_shopping_list_portions.select{|p|p[:type] == "individual_portion"}
      expect(indi_planner_portions.length).to eq 1
      expect(indi_planner_portions.first[:description]).to eq "1 Unit 2 Ingredient 2"

    end
  end

end
