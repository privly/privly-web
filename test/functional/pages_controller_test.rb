require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in  users(:one)
  end

  test "should get roadmap" do
    get :roadmap
    assert_response :success
  end

  test "should get privacy" do
    get :privacy
    assert_response :success
  end

  test "should get donate" do
    get :donate
    assert_response :success
  end

  test "should get download" do
    get :download
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end
  
  test "should get kickstarter" do
    get :kickstarter
    assert_response :success
  end
  
  test "should get account" do
    get :account
    assert_response :success
  end

end
