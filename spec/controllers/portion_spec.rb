require 'rails_helper'

describe PortionsController do
	context "with no logged in user" do
    it "should redirect create from post action" do
      post :create_from_post
      expect(response).to have_http_status(:redirect)
    end
	end


	context "with logged in user" do
		let!(:user) { create(:user) }
		before do
			user.confirm
			sign_in(user)
		end

		let!(:recipe) { create(:recipe, user_id: user.id) }
		let!(:recipe_steps) { create_list(:recipe_step, 3, recipe_id: recipe.id)}
		let!(:unit) { create(:unit) }
		let!(:ingredient) { create(:ingredient) }
		let(:headers) {{
      "ACCEPT": "application/json"
    }}

		it "should return bad request for post without params" do
			request.headers.merge! headers

			post :create_from_post, params: {}
			expect(response).to have_http_status(:bad_request)
		end

		it "should return ok for post with correct params" do
			request.headers.merge! headers

			expect(Portion.exists?(amount: 2, ingredient_id: ingredient.id, recipe_id: recipe.id, unit_id: unit.id)).to eq false

			post :create_from_post, params: {
				recipeId: recipe.id,
				ingredient: ingredient.id,
				unitId: unit.id,
				amount: 2
			}

			expect(response.content_type).to eq("application/json")
			expect(response).to have_http_status(:ok)
			expect(Portion.exists?(amount: 2, ingredient_id: ingredient.id, recipe_id: recipe.id, unit_id: unit.id)).to eq true
		end

		it "should return ok for post with correct params and new ingredient from string" do
			request.headers.merge! headers

			expect(Ingredient.exists?(name: "New ingredient")).to eq false
			expect(Portion.exists?(amount: 2, recipe_id: recipe.id, unit_id: unit.id)).to eq false

			post :create_from_post, params: {
				recipeId: recipe.id,
				ingredient: "New ingredient",
				unitId: unit.id,
				amount: 2
			}

			expect(response.content_type).to eq("application/json")
			expect(response).to have_http_status(:ok)
			expect(Ingredient.exists?(name: "New ingredient")).to eq true
			expect(Portion.exists?(amount: 2, ingredient_id: Ingredient.find_by(name: "New ingredient").id, recipe_id: recipe.id, unit_id: unit.id)).to eq true
		end
	end
end
