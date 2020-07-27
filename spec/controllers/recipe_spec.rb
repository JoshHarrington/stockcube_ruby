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
      # existing_steps_hash = {}
      # recipe_steps.each_with_index do |step, index|
      #   if index.odd?
      #     existing_steps_hash[step.id.to_s] = {"content": "Step number " + index.to_s}
      #   end
      # end
      # return existing_steps_hash

      {
        "#{existing_steps_hash[0].id}": {"content": "Step number 2"},
        "#{existing_steps_hash[0].id}": {"content": "Step number 1"},
        "#{existing_steps_hash[0].id}": {"content": "Step number 3"}
      }


    end

    let(:recipe_update_params) do
      current_last_step_number = adjusted_existing_steps_hash.sort_by{|k, v| v[:content].delete("^0-9").to_i }.last.last[:content].delete("^0-9").to_i
      return {
        "id": recipe.id,
        "recipe": {
          "steps": adjusted_existing_steps_hash,
        },
        "new_recipe_steps": ["New Step #{current_last_step_number + 1}", "New Step #{current_last_step_number + 2}"]
      }
    end

    it "recipe updating should keep consistent recipe step order" do
      put :update, params: recipe_update_params

      expect(response).to have_http_status(:redirect)

      updated_recipe_steps_sorted = RecipeStep.where(recipe_id: recipe.id).sort_by(&:number)

      p "updated_recipe_steps_sorted"
      p updated_recipe_steps_sorted.map{|s|[s.number,s.content]}

      expect(updated_recipe_steps_sorted.length).to eq 5

      updated_recipe_steps_sorted.each_with_index do |step, index|
        next if index == 0
        updated_recipe_steps_sorted[0..(index - 1)].each do |earlier_step|
          expect(step.content.delete("^0-9").to_i).to be > earlier_step.content.delete("^0-9").to_i
        end
      end
    end
  end
end
