# app/graphql/types/date.rb
class Types::Date < Types::BaseScalar
  description "A valid Date, transported as a DateTime"

  def self.coerce_input(input_value, context)
    # Parse the incoming object into a `DateTime`
    date = input_value.to_datetime
    if date.class.to_s == 'DateTime'
      # It's valid, return the date object
      date
    else
      raise GraphQL::CoercionError, "#{input_value.inspect} is not a valid DateTime"
    end
  end

  def self.coerce_result(ruby_value, context)
    # It's transported as a string, so stringify it
    ruby_value.to_date.to_s(:long)
  end
end