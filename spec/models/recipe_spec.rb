# spec/models/recipe_spec.rb

require 'rails_helper'

RSpec.describe Recipe, :type => :model do

  it "is valid with valid attributes" do
    recipe = Recipe.new(title: "A title")
    expect(recipe).to be_valid
  end

  it "is not valid without a title" do
    recipe = Recipe.new(title: nil)
    expect(recipe).to_not be_valid
  end

end
