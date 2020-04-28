module IntegerHelper
	def round_if_whole(number = nil)
		return if number == nil
		number.to_i == number ? number.to_i : number.round(1)
	end
end
