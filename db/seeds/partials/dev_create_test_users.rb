99.times do |n|
	name  = Faker::Name.name
	email = "example-#{n+1}@joshharrington.co.uk"
	password = "password"
	User.create!(name:  name,
	email: email,
	password:              password,
	password_confirmation: password,
	activated: true,
	activated_at: Time.zone.now)
end