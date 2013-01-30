require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in  users(:one)
    
    @post = posts(:one)
  end
  
  def assert_csv_creation(csv_row)
    
    assert_difference('Post.count') do
      post :create, :post => {:content => "Test Post 1", :public => true, 
        :share => {:share_csv => csv_row}}
        
      assert_redirected_to post_path(
        assigns(:post),
        :privlyInjectableApplication => "PlainPost",
        :privlyBurntAfter => assigns(:post).burn_after_date.to_i,
        :burntAfter => assigns(:post).burn_after_date.to_i,
        :privlyInject1 => true, 
        :random_token => assigns(:post).random_token)
      shares = assigns(:post).shares
      assert_not_nil shares.find_by_identity("@domainshare.com")
      assert_not_nil shares.find_by_identity("email@emailshare.com")
      assert_not_nil shares.find_by_identity("127.0.0.1")
    end
    
  end
  
  test "should create shares from CSV 1" do
    assert_csv_creation "@domainshare.com,email@emailshare.com,127.0.0.1"
  end
  
  test "should create shares from CSV 2" do
    assert_csv_creation "@domainshare.com, email@emailshare.com, 127.0.0.1"
  end
  
  test "should create shares from CSV 3" do
    assert_csv_creation "@domainshare.com, email@emailshare.com, 127.0.0.1"
  end
  
  test "should create shares from CSV 4" do
    assert_csv_creation"@domainshare.com ,email@emailshare.com ,127.0.0.1"
  end
  
  test "should create shares from CSV 5" do
    assert_csv_creation "@domainshare.com,      email@emailshare.com,127.0.0.1"
  end
  
  test "should create shares from CSV 6" do
    assert_csv_creation "@domainshare.com,email@emailshare.com,127.0.0.1     "
  end
  
  test "should create shares from CSV 7" do
    assert_csv_creation ",, , , ,, @domainshare.com,email@emailshare.com,127.0.0.1"
  end
  
  test "should create shares from CSV 8" do
    assert_csv_creation "     @domainshare.com,email@emailshare.com,127.0.0.1"
  end
  
  test "should create shares from CSV 9" do
    assert_csv_creation "@domainshare.com email@emailshare.com 127.0.0.1"
  end
  
  test "should create shares from CSV 10" do
    assert_csv_creation "@domainshare.com,email@emailshare.com 127.0.0.1"
  end
  
  test "should create shares from CSV 11" do
    assert_csv_creation "@domainshare.com,,email@emailshare.com,127.0.0.1"
  end
  
  test "should create shares from CSV 12" do
    assert_csv_creation "@domainshare.com, , email@emailshare.com,127.0.0.1"
  end
  
  test "should create shares from CSV 13" do
    assert_csv_creation "@domainshare.com     email@emailshare.com    127.0.0.1"
  end
end
