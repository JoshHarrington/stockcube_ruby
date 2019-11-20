require 'application_system_test_case'

class PlannerShoppingListsTest < ApplicationSystemTestCase

  include Devise::Test::IntegrationHelpers

  # setup do
  #   get new_user_session_url
    # fill_in 'input["user[name]"]', with: users(:tom)[:name]
  #   sign_in users(:tom)
  #   # post user_session_url
  #   # follow_redirect!
  #   # assert_response :success
  # end

  test "should get home" do
    # sign_in users(:tom)
    # visit planner_url
    # assert_selector '#dashboard .list_block--collection--sibling:first-child h2', text: "Recipes"


    visit root_url
    assert_selector '.feature-banner--title-tagline', text: "Say hello to"
  end

  # user = FactoryBot.create(:test_user)
  # login_as(user, :scope => :test_user)
  # user.confirmed_at = Time.now
  # user.save

  # test "visiting the planner" do
  #   visit planner_url

  #   assert_selector('#dashboard .list_block--collection--sibling:first-child h2',  text: "Recipes")

  #   Warden.test_reset!
  # end
end
