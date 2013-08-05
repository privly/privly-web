require 'test_helper'

class ZeroBinControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in  users(:one)
    
    @controller = ZeroBinsController.new
    @zero_bin = zero_bins(:one)
  end
  
  test "should get show" do
    
    # The burn_after date should be in the future
    assert_not_nil @zero_bin.burn_after_date
    assert @zero_bin.burn_after_date > Time.now
    
    get :show, :id => @zero_bin.id, :random_token => @zero_bin.random_token, 
      :format => :json
    assert_response :success
  end
  
  test "should deny show" do
    get :show, :id => @zero_bin.id
    assert_response(403)
  end
  
  test "should be burnt Zero Bin" do
    
    @zero_bin = zero_bins(:burnt)
    
    get :show, {:id => @zero_bin.id, :random_token => @zero_bin.random_token, 
      :format => "json"}
    error = JSON.parse(@response.body)
    assert error["error"] == "You do not have access or it doesn't exist."
    
  end

end
