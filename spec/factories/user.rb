FactoryBot.define do
  sequence :email_gen do |n|
    "email_#{n}@email.com"
  end
  factory :user do
    name { "Joanne Doe" }
    email { generate(:email_gen) }
    password { "th15is4gr8PA55W0RD" }
    admin { false }
    confirmed_at { Date.current }
  end
end
