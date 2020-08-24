require 'rails_helper'

describe RecipesController do

  context "with no logged in user" do
    it "should show recipe index" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "should redirect for creating new recipe" do
      get :new
      expect(response).to have_http_status(:redirect)
    end
  end

  context "with recipe steps added" do

    let!(:user) { create(:user) }
    before do
      user.confirm
      sign_in(user)
    end

    let!(:recipe) { create(:recipe) }
    let(:recipe_steps) { create_list(:recipe_step, 3, recipe_id: recipe.id)}

    it "should have recipe steps in the correct order" do
      expect(recipe_steps.first.number).to be < recipe_steps.last.number
    end

    let(:adjusted_existing_steps_hash) do
      {
        "#{recipe_steps[0].id}": {"content": "The first step"},
        "#{recipe_steps[1].id}": {"content": "The second step"},
        "#{recipe_steps[2].id}": {"content": recipe_steps[2].content}
      }
    end

    let(:recipe_update_params) do
      return {
        "id": recipe.id,
        "recipe": {
          "steps": adjusted_existing_steps_hash
        },
        "new_recipe_steps": ["New Step 1", "New Step 2"]
      }
    end

    it "recipe updating should keep consistent recipe step order" do
      put :update, params: recipe_update_params

      expect(response).to have_http_status(:redirect)

      updated_recipe_steps_sorted = RecipeStep.where(recipe_id: recipe.id).sort_by(&:number)

      expect(updated_recipe_steps_sorted.length).to eq 5

      updated_recipe_steps_sorted.each_with_index do |step, index|
        case index
        when 0
          expect(step.content).to eq "The first step"
        when 1
          expect(step.content).to eq "The second step"
        when 2
          expect(step.content).to eq recipe_steps[2].content
        when 3
          expect(step.content).to eq "New Step 1"
        when 4
          expect(step.content).to eq "New Step 2"
        end
      end
    end
  end

  context "with logged in user" do
    let!(:user) { create(:user) }
    before do
      user.confirm
      sign_in(user)
    end

    let!(:recipe) { create(:recipe) }

    it "should be able to favourite recipe" do
      get :favourite, params: {
        id: user.id,
        type: "favourite"
      }
      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to eq "Added the \"<a href=\"#{recipe_path(recipe)}\">#{recipe.title}</a>\" recipe to favourites"
    end

    it "should be able to unfavourite recipe" do
      get :favourite, params: {
        id: user.id,
        type: "unfavourite"
      }
      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to eq "Removed the \"<a href=\"#{recipe_path(recipe)}\">#{recipe.title}</a>\" recipe from favourites"
    end

  end

  context "with logged in user with json headers" do
    let!(:user) { create(:user) }
    before do
      user.confirm
      sign_in(user)
    end

    let!(:user_recipe) { create(:recipe, user_id: user.id) }
    let!(:non_user_recipe) { create(:recipe) }

    let!(:unit) { create(:unit) }
    let!(:ingredient) { create(:ingredient, unit_id: unit.id) }
    let!(:user_portion) { create(:portion, ingredient_id: ingredient.id, unit_id: unit.id, recipe_id: user_recipe.id) }
    let!(:non_user_portion) { create(:portion, ingredient_id: ingredient.id, unit_id: unit.id, recipe_id: non_user_recipe.id) }
    let(:headers) {{
      "ACCEPT": "application/json"
    }}

    it "should return not allowed for portion delete without portion id" do
      request.headers.merge! headers

      post :portion_delete, params: {}
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:forbidden)
    end

    it "should return ok for portion delete with available portion id" do
      request.headers.merge! headers

      post :portion_delete, params: {portion_id: user_portion.id}
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:ok)
    end

    it "should return not found for portion delete with available portion id but different user" do
      request.headers.merge! headers

      post :portion_delete, params: {portion_id: non_user_portion.id}
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:not_found)
    end
  end

  context "with logged in ADMIN user with json headers" do
    let!(:user) { create(:user, admin: true) }
    before do
      user.confirm
      sign_in(user)
    end

    let!(:non_user_recipe) { create(:recipe) }

    let!(:unit) { create(:unit) }
    let!(:ingredient) { create(:ingredient, unit_id: unit.id) }
    let!(:non_user_portion) { create(:portion, ingredient_id: ingredient.id, unit_id: unit.id, recipe_id: non_user_recipe.id) }
    let(:headers) {{
      "ACCEPT": "application/json"
    }}

    it "should return ok for portion delete with available portion id but different user" do
      request.headers.merge! headers

      post :portion_delete, params: {portion_id: non_user_portion.id}
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:ok)
    end
  end

  context "with logged OUT user with json headers" do
    let!(:user) { create(:user) }
    before do
      user.confirm
    end

    let!(:user_recipe) { create(:recipe, user_id: user.id) }

    let!(:unit) { create(:unit) }
    let!(:ingredient) { create(:ingredient, unit_id: unit.id) }
    let!(:user_portion) { create(:portion, ingredient_id: ingredient.id, unit_id: unit.id, recipe_id: user_recipe.id) }
    let(:headers) {{
      "ACCEPT": "application/json"
    }}

    it "should return unauthorized for add image" do
      request.headers.merge! headers

      post :add_image, params: {}
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with logged IN user with json headers" do
    let!(:user) { create(:user) }
    before do
      user.confirm
      sign_in(user)
    end

    let!(:user_recipe) { create(:recipe, user_id: user.id) }
    recipe_id_hash = Hashids.new(ENV['RECIPE_ID_SALT'])
    let!(:encoded_recipe_id) {
      recipe_id_hash.encode(user_recipe.id)
    }

    let!(:unit) { create(:unit) }
    let!(:ingredient) { create(:ingredient, unit_id: unit.id) }
    let!(:user_portion) { create(:portion, ingredient_id: ingredient.id, unit_id: unit.id, recipe_id: user_recipe.id) }
    let(:headers) {{
      "ACCEPT": "application/json"
    }}

    it "should return bad request for add image without params" do
      request.headers.merge! headers

      post :add_image, params: {}
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:bad_request)
    end

    it "should return bad request for add image with only image_path" do
      request.headers.merge! headers

      post :add_image, params: {image_path: "image_path"}
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:bad_request)
    end

    it "should return bad request for add image with only recipe_id" do
      request.headers.merge! headers

      post :add_image, params: {recipe_id: encoded_recipe_id}
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:bad_request)
    end

    it "should return ok for add image with all params" do
      request.headers.merge! headers

      post :add_image, params: {
        image_path: "image_path",
        recipe_id: encoded_recipe_id
      }
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:ok)
      expect(Recipe.find(user_recipe.id).image_url).to eq("image_path")
    end
  end

  context "with logged OUT user" do

    it "should respond redirect for favourites" do
      get :favourites

      expect(response.content_type).to eq("text/html")
      expect(response).to have_http_status(:redirect)
    end

    it "should respond redirect for your recipes" do
      get :yours

      expect(response.content_type).to eq("text/html")
      expect(response).to have_http_status(:redirect)
    end
  end

  context "with logged IN user" do
    let!(:user) { create(:user) }
    before do
      user.confirm
      sign_in(user)
    end

    it "should respond ok for favourites" do
      get :favourites

      expect(response.content_type).to eq("text/html")
      expect(response).to have_http_status(:ok)
    end

    it "should respond ok for your recipes" do
      get :yours

      expect(response.content_type).to eq("text/html")
      expect(response).to have_http_status(:ok)
    end
  end
end
