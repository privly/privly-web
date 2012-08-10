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
    get :show, :id => @zero_bin.id, :random_token => @zero_bin.random_token
    assert_response :success
  end
  
  test "should deny show" do
    get :show, :id => @zero_bin.id
    assert_response(403)
  end
  
  test "should get create" do
    
    post :create, :iv => "initialization_vector", 
      :salt => "salt", :ct => "encrypted_content", 
      :random_token => "random_access_token", 
      :burn_after_date => Time.now + 1.day
    assert_response :success
  end
  
  test "should be burnt Zero Bin" do
    
    @zero_bin = zero_bins(:burnt)
    
    get :show, {:id => @zero_bin.id, :random_token => @zero_bin.random_token, 
      :format => "json"}
    error = JSON.parse(@response.body)
    assert error["error"] == "record not found"
    
  end

end
