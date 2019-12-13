require "#{Rails.root}/app/task_helpers/csv_hash_helper"
include CsvHashHelper

desc "Add units from airtable csv"

task :add_airtable_units => :environment do
	unit_hash = process_csv_to_hash("./db/airtable_csvs/Units-Grid_view.csv")

	unit_hash.each do |row|
		content = row[1]
		Unit.find_or_create_by(
			name: content["name"],
			short_name: content["shortname"] || nil,
			metric_ratio: content["ratio"] || nil,
			unit_type: content["type"] || nil
		)
	end
end