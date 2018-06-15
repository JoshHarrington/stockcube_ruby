class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include ApplicationHelper

  # def metric_transform(portion_obj, portion_unit_obj)
	# 	metric_amount = portion_obj.amount * portion_unit_obj.metric_ratio

	# 	if metric_amount < 20
	# 		return metric_amount = metric_amount.ceil
	# 	elsif metric_amount < 400
	# 		return metric_amount = (metric_amount / 10).ceil * 10
	# 	elsif metric_amount < 1000
	# 		return metric_amount = (metric_amount / 20).ceil * 20
	# 	else
	# 		return metric_amount = (metric_amount / 50).ceil * 50
	# 	end
	# end

end
