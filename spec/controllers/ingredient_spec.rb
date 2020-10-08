require 'rails_helper'

describe IngredientsController do

  it "/ingredients should redirect to sign in if not logged in" do
    get :index
		expect(response).to redirect_to(new_user_session_path)
		expect(flash[:notice]).to eq nil
  end

end

describe IngredientsController do

  before { sign_in(user) }
  let!(:user) { create(:user, admin: false) }

  it "should not allow non-admin users to view ingredient list" do
    get :index
		expect(response).to redirect_to(root_path)
		expect(flash[:notice]).to eq "Only admins can edit ingredients directly"
  end
end

describe IngredientsController do

  before { sign_in(user) }
  let!(:user) { create(:user, admin: true) }

  it "should allow to admin users to view ingredient list" do
    get :index
    expect(response).to be_success
	end

	context "with existing ingredient" do
		let!(:ingredient) { create(:ingredient, name: "Ingredient 1", use_by_date_diff: 14) }
		let!(:units) { create_list(:unit, 2)}
		let!(:default_ingredient_size_1) { create(
			:default_ingredient_size,
			amount: 1,
			unit_id: units.first.id,
			ingredient_id: ingredient.id
		)}
		let!(:default_ingredient_size_2) { create(
			:default_ingredient_size,
			amount: 2,
			unit_id: units.second.id,
			ingredient_id: ingredient.id
		)}

		it "should allow ingredient update by admin user" do

			expect(Ingredient.exists?(ingredient.id)).to eq true
			expect(Ingredient.find(ingredient.id).name).to eq "Ingredient 1"
			expect(Ingredient.find(ingredient.id).default_ingredient_sizes.exists?(
				amount: 1,
				unit_id: units.first.id,
				ingredient_id: ingredient.id
			)).to eq true

			expect(Ingredient.find(ingredient.id).default_ingredient_sizes.exists?(
				amount: 2,
				unit_id: units.second.id,
				ingredient_id: ingredient.id
			)).to eq true

			expect(Ingredient.find(ingredient.id).default_ingredient_sizes.exists?(
				amount: 3,
				unit_id: units.first.id,
				ingredient_id: ingredient.id
			)).to eq false

			patch :update, params: {
				id: ingredient.id,
				ingredient: {
					name: "Ingredient 2",
					vegan: true,
					vegetarian: true,
					gluten_free: false,
					dairy_free: true,
					kosher: false,
					use_by_date_diff: 20
				},
				default_ingredient_sizes: {
					"#{default_ingredient_size_1.id}": {
						amount: default_ingredient_size_1.amount,
						unit_id: default_ingredient_size_1.unit_id
					},
					"#{default_ingredient_size_2.id}": {
						amount: default_ingredient_size_2.amount,
						unit_id: default_ingredient_size_2.unit_id,
						delete: true
					},
					new: [{
						amount: 3,
						unit_id: units.first.id
					},{
						amount: 4,
						unit_id: units.second.id
					}]
				}
			}

			ingredient_to_edit = Ingredient.find(ingredient.id)

			expect(ingredient_to_edit.name).to eq "Ingredient 2"
			expect(ingredient_to_edit.vegan).to eq true
			expect(ingredient_to_edit.vegetarian).to eq true
			expect(ingredient_to_edit.gluten_free).to eq false
			expect(ingredient_to_edit.dairy_free).to eq true
			expect(ingredient_to_edit.kosher).to eq false
			expect(ingredient_to_edit.use_by_date_diff).to eq 20

			expect(ingredient_to_edit.default_ingredient_sizes.exists?(
				amount: 1,
				unit_id: units.first.id,
				ingredient_id: ingredient.id
			)).to eq true

			expect(ingredient_to_edit.default_ingredient_sizes.exists?(
				amount: 2,
				unit_id: units.second.id,
				ingredient_id: ingredient.id
			)).to eq false

			expect(ingredient_to_edit.default_ingredient_sizes.exists?(
				amount: 3,
				unit_id: units.first.id,
				ingredient_id: ingredient.id
			)).to eq true

			expect(ingredient_to_edit.default_ingredient_sizes.exists?(
				amount: 4,
				unit_id: units.second.id,
				ingredient_id: ingredient.id
			)).to eq true

			expect(ingredient_to_edit.default_ingredient_sizes.exists?(
				amount: 5,
				unit_id: units.first.id,
				ingredient_id: ingredient.id
			)).to eq false
		end
	end
end
