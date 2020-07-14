require 'rails_helper'

describe PlannerController do

  it "planner should redirect to sign in if not logged in" do
    get :index
    expect(response).to redirect_to(new_user_session_path)
  end

end

RSpec.configure do |config|
  config.before(:example, exceptions: :catch) do
    allow(Rails.application.config.action_dispatch).to receive(:show_exceptions) { true }
  end
end

describe PlannerController do

  let!(:user) { create(:user) }
  before do
    sign_in(user)
    allow_any_instance_of(PlannerController).to receive(:current_user) { user }
  end

  it "should get planner" do
    get :index
    expect(response).to be_success
  end

  let!(:unit) { create(:unit)}
  let!(:ingredient) { create(:ingredient)}
  let!(:recipe) { create(:recipe)}
  let!(:portion) {
    create(
      :portion,
      ingredient_id: ingredient.id,
      recipe_id: recipe.id,
      unit_id: unit.id
    )
  }

  context "with valid parameters", exceptions: :catch do
    let(:valid_recipe_id) {recipe.id}
    let(:recipe_id_hash){Hashids.new(ENV['RECIPE_ID_SALT'])}
    let(:valid_params){{
      recipe_id: recipe_id_hash.encode(valid_recipe_id)
    }}
    let(:headers) {{
      "ACCEPT": "application/json"
    }}

    it "should let user add recipe to planner" do
      request.headers.merge! headers
      post :recipe_add_to_planner, params: valid_params

      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:ok)
      expect(PlannerRecipe.last[:recipe_id]).to eq valid_recipe_id
    end
  end

  context "with invalid parameters", exceptions: :catch do
    let(:invalid_recipe_id) {recipe.id.to_i + 1}
    let(:invalid_params) {{
      recipe_id: invalid_recipe_id
    }}
    let(:headers) {{
      "ACCEPT": "application/json"
    }}

    it "should not let user add recipe to planner" do
      request.headers.merge! headers
      post :recipe_add_to_planner, params: invalid_params
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:not_found)
      expect(PlannerRecipe.where(recipe_id: recipe.id.to_i + 1).length).to eq 0
    end
  end

end
