FactoryBot.define do
  sequence :unit_name do |n|
    "Unit #{n}"
  end
  factory :unit do
    name { generate(:unit_name) }
  end
end
