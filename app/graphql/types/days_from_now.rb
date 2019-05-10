require 'action_view'
include ActionView::Helpers::DateHelper

# app/graphql/types/days_from_now.rb
class Types::DaysFromNow < Types::BaseScalar
  description "Numbers of days from now, transported as a descriptive String"

  def self.coerce_input(input_value, context)
		input_value
  end

  def self.coerce_result(ruby_value, context)
		# It's transported as a string, so stringify it
		# days_from_now = distance_of_time_in_words(Time.zone.now, ruby_value) + (ruby_value <= Time.zone.now ? ' ago': '')
		if ruby_value.class.to_s == "Date"
			days_from_now = ruby_value - Date.current
		else
			days_from_now = ruby_value.to_date - Date.current
		end
  end
end