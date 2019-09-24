desc "Clear old database ready for new data"

task :clear_old_db => :environment do
	Unit.destroy_all
	Ingredient.destroy_all
	Recipe.destroy_all
end

