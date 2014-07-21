require 'test_helper'

class TokenAuthenticationsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  test "should lock account" do
    @user = User.find_by_email("test@test.com")
    
    for i in 0..9
      post :create, :email => @user.email, :password => "incorrect_password"
      assert_redirected_to new_token_authentication_path
      @user = User.find_by_email("test@test.com")
      assert @user.failed_attempts == i + 1
    end
    
    post :create, :email => @user.email, :password => "incorrect_password"
    assert @user.failed_attempts == Devise.maximum_attempts
    assert @user.access_locked?
    assert_redirected_to new_token_authentication_path
  end
  
  test "should get token authentication" do
    sign_in  users(:one)
    
    get :show
    assert_response :success
    
    get :show, :format => "json"
    assert_response :success
  end
  
  test "should create token authentication" do
    get :create, :email => users(:two).email, :password => "password"
    assert_not_nil assigns(:user).authentication_token
    assert_redirected_to show_token_authentications_path
  end
  
  test "should change token authentication" do
    get :create, :email => users(:one).email,
      :password => "password",
      :format => "json"
    assert_not_nil assigns(:user).authentication_token
    assert_not_equal assigns(:user).authentication_token, users(:one).authentication_token
    assert_redirected_to show_token_authentications_path(:format => "json")
  end
  
  test "should deny token authentication" do
    get :show
    assert_redirected_to new_user_session_path
    
    get :show, :format => "json"
    assert_response(302)
  end

end
