require 'csv'

module CsvHashHelper
	def process_csv_to_hash(file_path)
		csv_text = File.read(file_path)
		csv_first_parse = CSV.parse(csv_text, headers: true)  ## first parse, get it? ;)
		csv_nice_hash = {}
		csv_first_parse.by_row.each_with_index.map{|row, i| csv_nice_hash[i] = csv_first_parse.by_row[i].to_hash.transform_keys{ |key| key.to_s.gsub(/\s+/,'_').downcase.gsub(/\W+/, '') } }
		return csv_nice_hash
	end
end
