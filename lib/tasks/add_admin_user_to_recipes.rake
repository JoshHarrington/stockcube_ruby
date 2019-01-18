desc "Find admin user, set all recipes without user_id to have admin user user_id"
task :set_admin_user_as_recipe_user => :environment do
	admin = User.where(admin: true).first
	Recipe.all.each do |recipe|
		next if recipe.user_id != nil
		recipe.update_attributes(
			user_id: admin.id
		)
	end
end