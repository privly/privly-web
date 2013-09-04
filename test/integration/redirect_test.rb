require 'test_helper'

class RedirectTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  test "should get donate" do
    get "/pages/donate"
    assert_redirected_to "https://priv.ly/pages/donate"
  end

  test "should get download" do
    get "/pages/download"
    assert_redirected_to "https://priv.ly/pages/download"
  end

  test "should get about" do
    get "/pages/about"
    assert_redirected_to "https://priv.ly/pages/about"
  end

  test "should get kickstarter" do
    get "/pages/kickstarter"
    assert_redirected_to "https://priv.ly/pages/kickstarter"
  end

end
