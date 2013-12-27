require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  test "should get index" do
    get :index, :format => "html"
    assert_response :success
  end
  

end
