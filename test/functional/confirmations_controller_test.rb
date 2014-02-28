require 'test_helper'

class Users::ConfirmationsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers 
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  test "should resend confirmation instructions" do    
  	confirmation_sent_at = users(:one).confirmation_sent_at
  	assert_difference(confirmation_sent_at) do  
		  post :create, {:user => {:email => users(:one).email, :can_post => users(:one).can_post}}		  
		  assert_redirected_to new_user_session_path
		  assert_equal "If your e-mail exists on our database, you will receive an email with instructions about how to confirm your account in a few minutes.", flash[:notice]
		  confirmation_sent_at = users(:one).confirmation_sent_at
    end
  end
  
  test "should not resend confirmation instructions" do
  	confirmation_sent_at = users(:two).confirmation_sent_at
    assert_no_difference(confirmation_sent_at) do
      post :create, {:user => {:email => users(:two).email, :can_post => users(:two).can_post}}
      assert_redirected_to new_user_session_path
      assert_equal "If your e-mail exists on our database, you will receive an email with instructions about how to confirm your account in a few minutes.", flash[:notice]
      confirmation_sent_at = users(:two).confirmation_sent_at
    end
  end
  
  test "should not accept blank email" do
    confirmation_sent_at = users(:one).confirmation_sent_at
    assert_no_difference(confirmation_sent_at) do
      post :create, {:user => {:email => ""}}
      assert_redirected_to new_user_session_path
      assert_equal "If your e-mail exists on our database, you will receive an email with instructions about how to confirm your account in a few minutes.", flash[:notice]
      confirmation_sent_at = users(:one).confirmation_sent_at
    end
  end

end
