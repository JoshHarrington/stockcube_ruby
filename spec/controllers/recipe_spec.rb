require 'rails_helper'

describe RecipesController do

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
end
