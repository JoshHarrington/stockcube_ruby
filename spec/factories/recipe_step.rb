FactoryBot.define do
	sequence :recipe_step_number do |n|
    n.to_i
	end
	sequence :recipe_step_content do |n|
    "Step number #{n}"
  end
	factory :recipe_step do
		number { generate(:recipe_step_number) }
		content { generate(:recipe_step_content) }
	end
end
