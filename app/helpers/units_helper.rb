module UnitsHelper
	def unit_list(id = nil)
		unit_list = Unit.all.reject{|u| u.name == nil }.uniq{|u| u.name.downcase}.map{|u| {id: u.id, name: u.name.downcase}}
		if id == nil
			return unit_list
		else
			unit_name = unit_list.select{|u|u[:id] == id}.first[:name]
			return unit_name.to_s
		end
	end
end
