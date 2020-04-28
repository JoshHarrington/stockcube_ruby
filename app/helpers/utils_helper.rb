module UtilsHelper

	def standardise_amount_with_metric_ratio(amount = nil, metric_ratio = nil)
		return if amount == nil || metric_ratio == nil

		return amount * metric_ratio
  end

end
