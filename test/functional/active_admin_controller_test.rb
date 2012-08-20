require 'test_helper'

class ActiveAdminControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    
    @request.env["devise.mapping"] = Devise.mappings[:admin_user]
    sign_in  users(:one)
    
    @controller = ::Admin::UsersController.new 
  end

  test "should deny no user" do
    
    sign_out users(:one)
    
    get :index
    assert_redirected_to new_admin_user_session_path
    
    get :show, :id => 1
    assert_redirected_to new_admin_user_session_path
    
    get :new
    assert_redirected_to new_admin_user_session_path
    
    get :show, :id => 1
    assert_redirected_to new_admin_user_session_path
    
    post :create
    assert_redirected_to new_admin_user_session_path
    
    put :update, :id => 1
    assert_redirected_to new_admin_user_session_path
    
    get :edit, :id => 1
    assert_redirected_to new_admin_user_session_path
    
    delete :destroy, :id => 1
    assert_redirected_to new_admin_user_session_path
  end
  
  test "should deny non-admin user" do
    
    sign_out users(:one)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in  users(:one)
    
    get :index
    assert_redirected_to new_admin_user_session_path
    
    get :show, :id => 1
    assert_redirected_to new_admin_user_session_path
    
    get :new
    assert_redirected_to new_admin_user_session_path
    
    get :show, :id => 1
    assert_redirected_to new_admin_user_session_path
    
    post :create
    assert_redirected_to new_admin_user_session_path
    
    put :update, :id => 1
    assert_redirected_to new_admin_user_session_path
    
    get :edit, :id => 1
    assert_redirected_to new_admin_user_session_path
    
    delete :destroy, :id => 1
    assert_redirected_to new_admin_user_session_path
  end
  
  test "should allow admin user" do
    
    sign_in  admin_users(:one)
    
    get :index
    assert_response :success
    
    get :show, :id => 1
    assert_response :success
    
    get :new
    assert_response :success
    
    get :show, :id => 1
    assert_response :success
    
    post :create, {:email => "testemail@example.com", :password => "password",
      :password_confirmation => "password"}
    assert_redirected_to admin_user_path(:id => 1)
    
    put :update, :id => 1
    assert_redirected_to admin_user_path(:id => 1)
    
    get :edit, :id => 1
    assert_response :success
    
    delete :destroy, :id => 1
    assert_redirected_to admin_users_path
  end
  
end
