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
      expect(combi_planner_portions.first[:description]).to start_with("2")
      expect(combi_planner_portions.first[:description]).to include(units.first.name)
      expect(combi_planner_portions.first[:description]).to include(ingredients.first.name)

      indi_planner_portions = newly_processed_shopping_list_portions.select{|p|p[:type] == "individual_portion"}
      expect(indi_planner_portions.length).to eq 1
      expect(indi_planner_portions.first[:description]).to start_with("1")
      expect(indi_planner_portions.first[:description]).to include(units.last.name)
      expect(indi_planner_portions.first[:description]).to include(ingredients.last.name)

    end

    it "should show the correct cupboard portions" do
      units = create_list(:unit, 3)
      ingredients = create_list(:ingredient, 5)
      recipes = create_list(:recipe, 2)
      cupboard = user.cupboards.create(location: "Kitchen")
      portion_1 = create(:portion, ingredient_id: ingredients[0].id, recipe_id: recipes[0].id, unit_id: units[0].id)
      portion_2 = create(:portion, ingredient_id: ingredients[1].id, recipe_id: recipes[0].id, unit_id: units[1].id)
      portion_3 = create(:portion, ingredient_id: ingredients[2].id, recipe_id: recipes[0].id, unit_id: units[2].id)
      portion_4 = create(:portion, ingredient_id: ingredients[3].id, recipe_id: recipes[0].id, unit_id: units[1].id)
      portion_5 = create(:portion, ingredient_id: ingredients[4].id, recipe_id: recipes[0].id, unit_id: units[0].id)
      portion_6 = create(:portion, ingredient_id: ingredients[0].id, recipe_id: recipes[1].id, unit_id: units[0].id)
      portion_7 = create(:portion, ingredient_id: ingredients[1].id, recipe_id: recipes[1].id, unit_id: units[0].id)

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

      planner_portion = PlannerShoppingListPortion.find_by(planner_recipe_id: planner_recipe_1.id, ingredient_id: ingredients[2].id)
      planner_portion.update_attributes(checked: true)
      add_stock_after_portion_checked(planner_portion, "individual_portion")


      combi_portion = CombiPlannerShoppingListPortion.find_by(ingredient_id: ingredients[1].id)
      combi_portion.update_attributes(checked: true)
      combi_portion.planner_shopping_list_portions.update_all(
				checked: true
			)
      add_stock_after_portion_checked(combi_portion, "combi_portion")


      planner_recipes = processed_planner_recipes_with_date(user, true)
      planner_recipe_titles = planner_recipes.map{|pr| pr[:plannerRecipe][:title]}

      recipes.each do |r|
        expect(planner_recipe_titles).to include(r.title)
        planner_recipe_portions = planner_recipes.select{|pr| pr[:plannerRecipe][:title] == r.title}.first[:plannerRecipe][:portions]
        expect(planner_recipe_portions.length).to eq r.portions.length

        planner_recipe_stock = planner_recipe_portions.select{|p|p[:percentInCupboards] != 0}
        if r.title == recipes.first.title
          expect(planner_recipe_stock.length).to eq 2
        else
          expect(planner_recipe_stock.length).to eq 1
        end
      end

      fetched_shopping_list_portions = shopping_list_portions(nil, user)
      newly_processed_shopping_list_portions = processed_shopping_list_portions(fetched_shopping_list_portions)

      expect(fetched_shopping_list_portions.count{|p|p[:checked]}).to eq 2
      expect(fetched_shopping_list_portions.count).to eq 5

    end

    it "should not show hidden portions in shopping list" do
      units = create_list(:unit, 3)
      ingredients = create_list(:ingredient, 5)
      recipes = create_list(:recipe, 2)
      cupboard = user.cupboards.create(location: "Kitchen")
      portion_1 = create(:portion, ingredient_id: ingredients[0].id, recipe_id: recipes[0].id, unit_id: units[0].id)
      portion_2 = create(:portion, ingredient_id: ingredients[1].id, recipe_id: recipes[0].id, unit_id: units[1].id)
      portion_3 = create(:portion, ingredient_id: ingredients[2].id, recipe_id: recipes[0].id, unit_id: units[2].id)
      portion_4 = create(:portion, ingredient_id: ingredients[3].id, recipe_id: recipes[0].id, unit_id: units[1].id)
      portion_5 = create(:portion, ingredient_id: ingredients[4].id, recipe_id: recipes[0].id, unit_id: units[0].id)
      portion_6 = create(:portion, ingredient_id: ingredients[0].id, recipe_id: recipes[1].id, unit_id: units[0].id)
      portion_7 = create(:portion, ingredient_id: ingredients[1].id, recipe_id: recipes[1].id, unit_id: units[0].id)

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

      combi_portion_to_hide = CombiPlannerShoppingListPortion.find_by(ingredient_id: ingredients[1].id)
      combi_portion_to_hide_desc = serving_description(combi_portion_to_hide)

      p CombiPlannerShoppingListPortion.all.map{|cp| [cp, serving_description(cp)]}

      request.headers.merge! headers
      post :hide_portion, params: {
        encoded_id: planner_portion_id_hash.encode(combi_portion_to_hide.id),
        portion_type: "combi_portion"
      }

      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:ok)

      response_body = JSON.parse(response.body)

      expect(response_body["portionDescription"]).to eq combi_portion_to_hide_desc

      response_combi_portions = response_body["shoppingListPortions"].select{|p|p["type"] == "combi_portion"}

      expect(response_combi_portions.length).to eq 1
      expect(response_combi_portions.first["description"]).not_to eq combi_portion_to_hide_desc

    end
  end

end
