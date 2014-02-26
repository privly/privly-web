require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in  users(:one)
    @post = posts(:one)
  end

  test "should destroy user account" do
    post_count = Post.count
    assert_difference('User.count', -1) do
      delete :destroy
    end
    assert Post.count < post_count
    assert_redirected_to welcome_path
  end

  test "should not destroy user account" do
    sign_out users(:one)
    post_count = Post.count
    assert_difference('User.count', 0) do
      delete :destroy
    end
    assert Post.count == post_count
    assert_redirected_to welcome_path
  end

end
