require 'test_helper'

class EmailShareControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in  users(:one)
    
    @controller = EmailSharesController.new
    
    @email_share = email_shares(:one)
    
  end
  
  
  test "should post create" do
    assert_difference('EmailShare.count') do
      post :create, :email_share => {:post_id => 1, :email => "email22@email.com", 
        :can_show => true, :can_destroy => true, 
        :can_update => true, :can_share => true}
    end
  end

  test "should delete destroy" do
    current_post = @email_share.post
    assert_difference('EmailShare.count', -1) do
      delete :destroy, :id => @email_share.id
    end
    assert_redirected_to post_path(current_post)
  end

end
