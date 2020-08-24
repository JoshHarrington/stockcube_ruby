FactoryBot.define do
  sequence :cupboard_name do |n|
    "Cupboard #{n}"
  end
  factory :cupboard do
    location { generate(:cupboard_name) }
  end
end
