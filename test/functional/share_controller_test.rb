require 'test_helper'

class ShareControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in  users(:one)
    
    @controller = SharesController.new
    
    @share = shares(:one)
    
  end
  
  test "should post create" do
    assert_difference('Share.count') do
      post :create, :share => {:post_id => 1,
        :identity => "email22@email.com",
        :identity_provider_name => "Privly Verified Email",
        :can_show => true, :can_destroy => true, 
        :can_update => true, :can_share => true}
    end
  end
  
  test "should update post" do
    assert @share.can_share
    put :update, :id => @share.to_param, :share => {:can_share => false}
    assert_redirected_to post_path(@share.post)
  end

  test "should delete destroy" do
    current_post = @share.post
    assert_difference('Share.count', -1) do
      delete :destroy, :id => @share.id
    end
    assert_redirected_to post_path(current_post)
  end

end
