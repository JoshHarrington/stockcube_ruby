namespace :new_ingredients do
	desc "Find or add new ingredients"
	task :find_or_create_new_ingredients => :environment do
		loaf_unit_id = Unit.find_or_create_by(name: "Loaf", short_name: "loaf")
		Ingredient.find_or_create_by(name: "Bread (White)", vegan: false, vegetarian: true, gluten_free: false, dairy_free: false, kosher: false, common: true, searchable: true, unit_id: loaf_unit_id)
		Ingredient.find_or_create_by(name: "Bread (Brown)", vegan: false, vegetarian: true, gluten_free: false, dairy_free: false, kosher: false, common: false, searchable: false, unit_id: loaf_unit_id)
		Ingredient.find_or_create_by(name: "Bread (Sourdough)", vegan: false, vegetarian: true, gluten_free: false, dairy_free: false, kosher: false, common: false, searchable: false, unit_id: loaf_unit_id)
	end
end
