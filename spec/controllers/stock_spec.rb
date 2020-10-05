require 'rails_helper'

describe StocksController do
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

		let!(:cupboard) { create(:cupboard) }
		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		let!(:encoded_cupboard_id) { cupboard_id_hashids.encode(cupboard.id) }
		let!(:cupboard_user) { create(:cupboard_user, user_id: user.id, cupboard_id: cupboard.id )}

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

			expect(Stock.exists?(amount: 2, ingredient_id: ingredient.id, unit_id: unit.id, cupboard_id: cupboard.id)).to eq false
			expect(Ingredient.order(created_at: :desc).first.id).to eq ingredient.id

			post :create_from_post, params: {
				cupboardId: encoded_cupboard_id,
				ingredient: ingredient.id,
				unitId: unit.id,
				amount: 2,
				useByDate: Date.current + 14.days,
				isNewIngredient: false
			}

			expect(response.content_type).to eq("application/json")
			expect(response).to have_http_status(:ok)

			expect(Stock.all.length).to eq 1
			stock = Stock.first
			expect(stock.amount).to eq 2
			expect(stock.ingredient_id).to eq ingredient.id
			expect(stock.cupboard_id).to eq cupboard.id
			expect(stock.unit_id).to eq unit.id
			expect(stock.use_by_date).to eq Date.current + 14.days
			expect(stock.use_by_date.to_date).to eq Date.current + 14.days
		end

		it "should return ok for post with correct params and new ingredient from string" do
			request.headers.merge! headers

			expect(Ingredient.exists?(name: "New ingredient")).to eq false
			expect(Stock.exists?(
				amount: 2,
				cupboard_id: cupboard.id,
				unit_id: unit.id
			)).to eq false

			post :create_from_post, params: {
				cupboardId: encoded_cupboard_id,
				ingredient: "New ingredient",
				unitId: unit.id,
				amount: 2,
				useByDate: Date.current + 14.days,
				isNewIngredient: true
			}

			expect(response.content_type).to eq("application/json")
			expect(response).to have_http_status(:ok)
			expect(Ingredient.exists?(name: "New ingredient")).to eq true
			expect(Stock.exists?(
				amount: 2,
				ingredient_id: Ingredient.find_by(name: "New ingredient").id,
				cupboard_id: cupboard.id,
				unit_id: unit.id,
				use_by_date: Date.current + 14.days
			)).to eq true
		end
	end

	context "with logged in user and existing stock" do
		let!(:user) { create(:user) }
		before do
			user.confirm
			sign_in(user)
		end

		let!(:cupboard) { create(:cupboard) }
		cupboard_id_hashids = Hashids.new(ENV['CUPBOARDS_ID_SALT'])
		let!(:encoded_cupboard_id) { cupboard_id_hashids.encode(cupboard.id) }
		let!(:cupboard_user) { create(:cupboard_user, user_id: user.id, cupboard_id: cupboard.id )}

		let!(:unit) { create(:unit) }
		let!(:ingredient) { create(:ingredient) }
		let!(:stock) {create(:stock, amount: 1, use_by_date: Date.current + 7.days, ingredient_id: ingredient.id, unit_id: unit.id, cupboard_id: cupboard.id)}
		let!(:stock_user) { create(:stock_user, stock_id: stock.id, user_id: user.id)}

		let(:headers) {{
      "ACCEPT": "application/json"
    }}

		it "should return bad request for post without params" do
			request.headers.merge! headers

			post :update_from_post, params: {}
			expect(response).to have_http_status(:bad_request)
		end

		it "should return ok for post with correct params" do
			request.headers.merge! headers

			expect(Stock.exists?(id: stock.id, amount: 1, ingredient_id: ingredient.id, unit_id: unit.id, cupboard_id: cupboard.id)).to eq true

			post :update_from_post, params: {
				cupboardId: cupboard.id,
				stockId: stock.id,
				unitId: unit.id,
				amount: 2,
				useByDate: (Date.current + 14.days).strftime("%F")
			}

			expect(response.content_type).to eq("application/json")
			expect(response).to have_http_status(:ok)
			expect(Stock.exists?(id: stock.id, amount: 2, ingredient_id: ingredient.id, cupboard_id: cupboard.id, unit_id: unit.id, use_by_date: Date.current + 14.days)).to eq true
		end
	end
end
