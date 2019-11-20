require 'test_helper'

class PlannerShoppingListsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
  #   get new_user_session_url
    sign_in users(:tom)
  #   post user_session_url
  #   follow_redirect!
  #   assert_response :success
  end

  test "should be redirected if not logged in" do
    sign_out :user
    get planner_url
    assert_response :redirect
    # assert_selector '#dashboard .list_block--collection--sibling:first-child h2', text: "Recipes"
  end

  test "should get planner" do
    get planner_url
    assert_response :success
    # assert_selector '#dashboard .list_block--collection--sibling:first-child h2', text: "Recipes"
  end

  # test "should get new" do
  #   get new_planner_shopping_list_url
  #   assert_response :success
  # end

  # test "should create planner_shopping_list" do
  #   assert_difference('PlannerShoppingList.count') do
  #     post planner_shopping_lists_url, params: { planner_shopping_list: {  } }
  #   end

  #   assert_redirected_to planner_shopping_list_url(PlannerShoppingList.last)
  # end

  # test "should show planner_shopping_list" do
  #   get planner_shopping_list_url(@planner_shopping_list)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get edit_planner_shopping_list_url(@planner_shopping_list)
  #   assert_response :success
  # end

  # test "should update planner_shopping_list" do
  #   patch planner_shopping_list_url(@planner_shopping_list), params: { planner_shopping_list: {  } }
  #   assert_redirected_to planner_shopping_list_url(@planner_shopping_list)
  # end

  # test "should destroy planner_shopping_list" do
  #   assert_difference('PlannerShoppingList.count', -1) do
  #     delete planner_shopping_list_url(@planner_shopping_list)
  #   end

  #   assert_redirected_to planner_shopping_lists_url
  # end
end
