class AddPrepCookTimeAndYieldToRecipes < ActiveRecord::Migration[5.1]
  def change
    add_column :recipes, :prep_time, :string
    add_column :recipes, :cook_time, :string
    add_column :recipes, :yield, :string
  end
end
