admin_user = User.create(name:  "Admin User",
			email: ENV['PERSONAL_ADMIN_EMAIL'],
			password:              ENV['PERSONAL_PASSWORD'],
			password_confirmation: ENV['PERSONAL_PASSWORD'],
			admin: true,
			activated: true,
      activated_at: Time.zone.now)

chantelle_user = User.create(name:  "Chantelle",
			email: ENV['CHANTELLE_ADMIN_EMAIL'],
			password:              ENV['CHANTELLE_ADMIN_PASSWORD'],
			password_confirmation: ENV['CHANTELLE_ADMIN_PASSWORD'],
			admin: true,
			activated: true,
			activated_at: Time.zone.now)

standard_user = User.create(name:  "Standard User",
			email: ENV['PERSONAL_STANDARD_EMAIL'],
			password:              ENV['PERSONAL_PASSWORD'],
			password_confirmation: ENV['PERSONAL_PASSWORD'],
			activated: true,
			activated_at: Time.zone.now)

c1 = Cupboard.create(location: "Fridge Door")
c2 = Cupboard.create(location: "Fridge Bottom Drawer")
c3 = Cupboard.create(location: "Fridge Top Shelf")
c4 = Cupboard.create(location: "Cupboard by the Oven")


[c1, c3, c4].each do |c|
	CupboardUser.create(
		cupboard_id: c.id,
		user_id: admin_user.id,
		owner: true,
		accepted: true
	)
end

CupboardUser.create(
	cupboard_id: c2.id,
	user_id: standard_user.id,
	owner: true,
	accepted: true
)


ingredient_picks = Ingredient.all.sample(15)

ingredient_picks.each_with_index do |ingredient, index|

  ingredient_obj = Ingredient.where(id: ingredient.id).first

	cupboard_pick_id = CupboardUser.where(user_id: admin_user.id).sample.cupboard_id

  test_use_by_date = Date.today + 2.weeks + index.days

  stock = Stock.create(
    amount: 0.1,
    use_by_date: test_use_by_date,
    unit_id: ingredient_obj.unit_id,
    cupboard_id: cupboard_pick_id,
    ingredient_id: ingredient_obj.id
  )

end
