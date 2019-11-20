ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
 fixtures :all

 include Devise::Test::IntegrationHelpers

 def login_user
  user = User.create(name: "Alice Bennett", email: "alice@example.com", password: "wertyu345678sdfgh", password_confirmation: "wertyu345678sdfgh")
  user.confirm
 end
end
