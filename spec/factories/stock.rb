FactoryBot.define do
	factory :stock do
		amount { 1 }
		use_by_date { Date.current + 14.days}
  end
end
