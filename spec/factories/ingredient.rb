FactoryBot.define do
  sequence :ingredient_name do |n|
    "Ingredient #{n}"
  end
  factory :ingredient do
    use_by_date_diff { 14 }
    name { generate(:ingredient_name) }
  end
end
