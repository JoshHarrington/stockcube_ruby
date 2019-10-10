module IntegerHelper
	def round_if_whole(number)
		number.to_i == number ? number.to_i : number.round(-1)
	end
end
