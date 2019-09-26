desc "Make all recipes live"
task :make_recipes_live => :environment do
	Recipe.all.each do |recipe|
		next unless recipe.user.admin == true
		recipe.update_attributes(
			public: true,
			live: true
		)
	end
end
