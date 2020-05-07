module UnitsHelper
	def unit_list(unit_type = "All")

		uniq_units = Unit.all.reject{|u| u.name == nil }.uniq{|u| u.name.downcase}

		if unit_type == "Volume"
			return uniq_units.select{|u|u.unit_type == "Volume"}.map{|u| {id: u.id, name: u.name.downcase}}
		elsif unit_type == "Mass"
			return uniq_units.select{|u|u.unit_type == "Mass"}.map{|u| {id: u.id, name: u.name.downcase}}
		elsif unit_type == nil
			return uniq_units.select{|u|u.unit_type == nil}.map{|u| {id: u.id, name: u.name.downcase}}
		else
			return uniq_units.map{|u| {id: u.id, name: u.name.downcase}}
		end
	end

	def unit_list_for_select(unit_type = 'All')

		return unit_list(unit_type).collect{|u| [u[:name], u[:id]] }
	end

	def unit_name(id = nil)
		return if id == nil
		unit_name = unit_list().select{|u|u[:id] == id}.first[:name]
		return unit_name.to_s
	end
end
