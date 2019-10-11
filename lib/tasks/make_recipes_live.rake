desc "Make all recipes live"
task :make_recipes_live => :environment do
	admin = User.find_by(admin: true)
	Recipe.all.each do |recipe|
		next if admin == nil || (recipe.user && recipe.user.admin == false)
		recipe.update_attributes(
			public: true,
			live: true
		)
	end
end
