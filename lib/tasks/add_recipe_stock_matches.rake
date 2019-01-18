require "#{Rails.root}/app/task_helpers/stock_helper"
include TaskStockHelper

desc "setup recipe stock matches if stock exists, otherwise set all columns to 0"
task :find_user_add_recipe_stock_matches => :environment do

	User.all.each do |set_user|
		TaskStockHelper.recipe_stock_matches_update(set_user[:id], nil)
	end

end