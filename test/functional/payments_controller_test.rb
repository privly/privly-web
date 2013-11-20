require 'test_helper'

class PaymentsControllerTest < ActionController::TestCase
  test "should get donate" do
    get :donate
    assert_response :success
  end

end
