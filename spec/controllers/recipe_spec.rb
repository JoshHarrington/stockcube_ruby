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
    let!(:recipe_steps) { create_list(:recipe_step, 3, recipe_id: recipe.id)}

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
        id: recipe.id,
        type: "favourite"
      }
      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to eq "Added the \"<a href=\"#{recipe_path(recipe)}\">#{recipe.title}</a>\" recipe to favourites"
    end

    it "should be able to unfavourite recipe" do
      get :favourite, params: {
        id: recipe.id,
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


    let!(:recipe) { create(:recipe) }

    it "should not be able to edit recipe" do
      get :edit, params: {id: recipe.id}

      expect(response).to have_http_status(:redirect)
    end

    it "should not be able to edit recipe" do
      get :update, params: {id: recipe.id}

      expect(response).to have_http_status(:redirect)
    end

    it "should be able to view a recipe" do
      get :show, params: {id: recipe.id}

      expect(response).to have_http_status(:ok)
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

  context "with logged IN user with relevant stock" do
    let!(:user) { create(:user) }
    before do
      user.confirm
      sign_in(user)
    end

    let!(:recipe) { create(:recipe, user_id: user.id) }

    let!(:unit) { create(:unit) }
    let!(:ingredient) { create(:ingredient, unit_id: unit.id) }
    let!(:portion) { create(:portion, ingredient_id: ingredient.id, unit_id: unit.id, recipe_id: recipe.id) }

    let!(:cupboard) { create(:cupboard) }
    let!(:cupboard_user) { create(:cupboard_user, cupboard_id: cupboard.id, user_id: user.id) }
    let!(:stock) { create(:stock, ingredient_id: ingredient.id, unit_id: unit.id, cupboard_id: cupboard.id) }

    it "should create UserRecipeStockMatch" do
      expect(UserRecipeStockMatch.all.length).to eq(0)

      post :update_recipe_matches
      expect(UserRecipeStockMatch.all.length).to eq(1)
    end
  end


  context "with logged IN user and recipe that IS NOT publishable" do
    let!(:user) { create(:user) }
    before do
      user.confirm
      sign_in(user)
    end

    let!(:recipe) { create(:recipe, live: false, user_id: user.id) }
    let!(:unit) { create(:unit) }
    let!(:ingredient) { create(:ingredient, unit_id: unit.id) }
    let!(:user_portion) { create(:portion, ingredient_id: ingredient.id, unit_id: unit.id, recipe_id: recipe.id) }

    it "should return that this recipe CANNOT be published" do
      expect(publishable_state_check(recipe: recipe)).to eq false
    end

    it "should return bad request if no type" do
      get :publish_update, params: { id: recipe.id }

      expect(response).to have_http_status(:redirect)
      expect(Recipe.find(recipe.id).live).to eq false
      expect(flash[:notice]).to eq "Something went wrong. That recipe change didn't go through"
    end

    it "should redirect if type is set to empty string" do
      get :publish_update, params: { type: "", id: recipe.id }
      expect(response).to have_http_status(:redirect)
      expect(Recipe.find(recipe.id).live).to eq false
      expect(flash[:notice]).to eq "Something went wrong. That recipe change didn't go through"
    end

    it "should redirect and set recipe live if type is make_live" do
      get :publish_update, params: {
        id: recipe.id.to_s,
        type: "make_live"
      }

      expect(response).to have_http_status(:redirect)
      expect(Recipe.find(recipe.id).live).to eq false
      expect(flash[:notice]).to eq "That recipe needs completing before it can be made live"
    end

    it "should redirect and set recipe live to false if type is make_draft" do
      get :publish_update, params: {
        id: recipe.id.to_s,
        type: "make_draft"
      }

      expect(response).to have_http_status(:redirect)
      expect(Recipe.find(recipe.id).live).to eq false
      expect(Recipe.find(recipe.id).public).to eq false
      expect(flash[:notice]).to eq "#{recipe.title} is now in draft mode"
    end

    it "should redirect and set recipe public to true if type is make_public" do
      get :publish_update, params: {
        id: recipe.id.to_s,
        type: "make_public"
      }

      expect(response).to have_http_status(:redirect)
      expect(Recipe.find(recipe.id).live).to eq false
      expect(Recipe.find(recipe.id).public).to eq false
      expect(flash[:notice]).to eq "That recipe needs completing before it can be made public"
    end

  end

  context "with logged IN user and recipe that IS publishable" do
    let!(:user) { create(:user) }
    before do
      user.confirm
      sign_in(user)
    end

    let!(:recipe) { create(:recipe, live: false, user_id: user.id) }
    let!(:unit) { create(:unit) }
    let!(:ingredient) { create(:ingredient, unit_id: unit.id) }
    let!(:user_portion) { create(:portion, ingredient_id: ingredient.id, unit_id: unit.id, recipe_id: recipe.id) }
    let!(:recipe_steps) { create_list(:recipe_step, 3, recipe_id: recipe.id)}

    it "should return that this recipe CAN be published" do
      expect(publishable_state_check(recipe: recipe)).to eq true
    end

    it "should return bad request if no type" do
      get :publish_update, params: { id: recipe.id }

      expect(response).to have_http_status(:redirect)
      expect(Recipe.find(recipe.id).live).to eq false
      expect(flash[:notice]).to eq "Something went wrong. That recipe change didn't go through"
    end

    it "should redirect if type is set to empty string" do
      get :publish_update, params: { type: "", id: recipe.id }
      expect(response).to have_http_status(:redirect)
      expect(Recipe.find(recipe.id).live).to eq false
      expect(flash[:notice]).to eq "Something went wrong. That recipe change didn't go through"
    end

    it "should redirect and set recipe live if type is make_live" do
      get :publish_update, params: {
        id: recipe.id.to_s,
        type: "make_live"
      }

      expect(response).to have_http_status(:redirect)
      expect(Recipe.find(recipe.id).live).to eq true
      expect(flash[:notice]).to eq "#{recipe.title} is now live and public!"
    end

    it "should redirect and set recipe live to false if type is make_draft" do
      get :publish_update, params: {
        id: recipe.id.to_s,
        type: "make_draft"
      }

      expect(response).to have_http_status(:redirect)
      expect(Recipe.find(recipe.id).live).to eq false
      expect(Recipe.find(recipe.id).public).to eq false
      expect(flash[:notice]).to eq "#{recipe.title} is now in draft mode"
    end

    it "should redirect and set recipe public to true if type is make_public" do
      get :publish_update, params: {
        id: recipe.id.to_s,
        type: "make_public"
      }

      expect(response).to have_http_status(:redirect)
      expect(Recipe.find(recipe.id).live).to eq true
      expect(Recipe.find(recipe.id).public).to eq true
      expect(flash[:notice]).to eq "#{recipe.title} is live and public"
    end

  end

  context "with different users and recipe" do
    let!(:first_user) { create(:user) }
    let!(:second_user) { create(:user) }
    let!(:admin_user) { create(:user, admin: true)}

    let!(:recipe) { create(:recipe, user_id: first_user.id) }
    let!(:unit) { create(:unit) }
    let!(:ingredient) { create(:ingredient, unit_id: unit.id) }
    let!(:portion) { create(:portion, ingredient_id: ingredient.id, unit_id: unit.id, recipe_id: recipe.id) }
    let!(:recipe_steps) { create_list(:recipe_step, 3, recipe_id: recipe.id)}

    it "should return true that a recipe owner can edit this recipe" do
      expect(recipe_exists_and_can_be_edited(recipe_id: recipe.id, user: first_user)).to eq true
      expect(recipe_exists_and_can_be_edited(recipe_id: recipe.id.to_s, user: first_user)).to eq true
    end

    it "should return false that another user can edit this recipe" do
      expect(recipe_exists_and_can_be_edited(recipe_id: recipe.id, user: second_user)).to eq false
    end

    it "should return true that an admin user can edit this recipe" do
      expect(recipe_exists_and_can_be_edited(recipe_id: recipe.id, user: admin_user)).to eq true
    end

  end

end
