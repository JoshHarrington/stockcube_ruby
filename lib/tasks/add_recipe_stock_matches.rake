# include StockHelper

desc "setup recipe stock matches if stock exists, otherwise set all columns to 0"
task :find_user_add_recipe_stock_matches => :environment do

	User.all.each do |set_user|
		# recipe_stock_matches_update(set_user[:id], nil)
	end

end