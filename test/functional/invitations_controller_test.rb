require 'test_helper'

class Users::InvitationsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers 
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  test "should send invitation" do
    sign_in users(:one)
    assert_difference("User.count") do
      post :use_invite, {:user => {:email => "newEmail5@email.com"}}
      assert assigns(:user).alpha_invites == 0
      assert_redirected_to pages_account_path
      assert_equal "We emailed newemail5@email.com with an invitation.", flash[:notice]
    end
  end
  
  test "should not send invitation" do
    sign_in users(:two)
    assert_no_difference('User.count') do
      post :use_invite, {:user => {:email => "newEmail@email.com"}}
      assert_redirected_to pages_account_path
      assert_equal "You do not have any invitations at this time.", flash[:notice]
    end
  end
  
  test "should create invitation" do
    assert_difference('User.count') do
      post :create, {:user => {:email => "newEmail@email.com"}}
      assert_redirected_to welcome_path
      assert_equal "Thanks #{assigns(:user).email}! When we are ready for more users we will send you a message.", flash[:notice]
    end
  end
  
  test "should obscure that user account already exists" do
    assert_difference('User.count', 0) do
      post :create, {:user => {:email => users(:one).email}}
      assert_redirected_to welcome_path
      assert_equal "Thanks #{users(:one).email}! When we are ready for more users we will send you a message.", flash[:notice]
    end
  end
  
  test "should not create blank invitation" do
    assert_difference('User.count', 0) do
      post :create, {:user => {:email => ""}}
      assert_redirected_to welcome_path
    end
  end
  
end
