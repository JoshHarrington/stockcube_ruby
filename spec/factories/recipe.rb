FactoryBot.define do
  sequence :recipe_name do |n|
    "Recipe #{n}"
  end
  factory :recipe do
    title { generate(:recipe_name) }
    live { true }
    public { true }
    cook_time { 30 }
  end
end
