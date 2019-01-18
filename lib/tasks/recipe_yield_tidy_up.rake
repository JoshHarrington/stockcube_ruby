desc "Tidy up recipe yield to remove servings text and delete ranges"

task :recipe_yield_tidy_up => :environment do
	Recipe.all.each do |recipe|
		next if recipe.yield == nil
		clean_yield = recipe.yield.to_s.downcase.gsub(/\sservings/, '').gsub(/(\d+)\sto\s\d+/, '\1').gsub(/(\d+)\s\-\s\d+/, '\1')
		recipe.update_attributes(
			yield: clean_yield
		)
	end
end