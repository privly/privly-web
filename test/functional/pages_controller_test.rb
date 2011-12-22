require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get faq" do
    get :faq
    assert_response :success
  end

  test "should get join" do
    get :join
    assert_response :success
  end

  test "should get roadmap" do
    get :roadmap
    assert_response :success
  end

  test "should get people" do
    get :people
    assert_response :success
  end

  test "should get license" do
    get :license
    assert_response :success
  end

  test "should get privacy" do
    get :privacy
    assert_response :success
  end

  test "should get terms" do
    get :terms
    assert_response :success
  end

  test "should get help" do
    get :help
    assert_response :success
  end

  test "should get status" do
    get :status
    assert_response :success
  end

  test "should get irc" do
    get :irc
    assert_response :success
  end

  test "should get bug" do
    get :bug
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

  test "should get email" do
    get :email
    assert_response :success
  end

end
