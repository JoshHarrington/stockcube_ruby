class Quantity

	attr_reader :amount, :unit

	def initialize(amount, unit)
		@amount = amount
		@unit = unit
	end

	def comparable_amount
    if unit_model.metric_ratio
      amount * unit_model.metric_ratio
    else
      amount
    end
	end

	private

	def unit_model
		Unit.where(name: unit).first
	end

end