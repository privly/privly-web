require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in  users(:one)
    @post = posts(:one)
  end

  test "should get index" do
    get :index
    assert_redirected_to "/apps/Index/new.html"
  end

  test "should create post" do
    sign_in  users(:one)
    assert_difference('Post.count') do
      post :create, :post => {:content => "Test Post 1", :public => true}
    end
    assert_redirected_to assigns(:post).privly_URL
  end
  
  test "should create post with seconds_until_burn" do
    sign_in  users(:one)
    assert_difference('Post.count') do
      post :create, :post => {:content => "Test Post 1", :public => true,
        :seconds_until_burn => 5}
    end
    assert_redirected_to assigns(:post).privly_URL
  end
  
  test "should create structured content post" do
    sign_in  users(:one)
    assert_difference('Post.count') do
      post :create, :post => {
                      :structured_content => {
                        :this_will_be_serialized => "Test Post 1"
                        }, :public => true, :privly_application => "FakeApp"}
    end
    assert assigns(:post).structured_content[:this_will_be_serialized] == "Test Post 1"
    assert_redirected_to assigns(:post).privly_URL
  end

  test "should show post no format" do
    get :show, :id => @post.to_param
    assert_response :success
  end
  
  test "should show json format post" do
    get :show, :id => @post.to_param, :format => "json"
    assert_response :success
  end
  
  test "should deny show post" do
    sign_out users(:one)
    get :show, :id => @post.id
    assert_redirected_to new_user_session_path
  end
  
  test "should deny show json post" do
    sign_out users(:one)
    get :show, {:id => @post.id, :format => "json"}
    error = JSON.parse(@response.body)
    assert error["error"] == "No access or it does not exist. You might have access to this if you login."
  end
  
  test "should be burnt post no format" do
    @post = posts(:burnt)
    get :show, :id => @post.id
    assert_template "posts/noaccess"
  end
  
  test "should be burnt post json" do
    @post = posts(:burnt)
    get :show, {:id => @post.id, :format => "json"}
    error = JSON.parse(@response.body)
    assert error["error"] == "You do not have access or it doesn't exist."
  end

  test "should show post without random token" do
    sign_out users(:one)
    @post = posts(:two)
    get :show, :id => @post.to_param
    assert_response :success
  end
  
  test "should deny signed in show post without random token" do
    sign_out users(:one)
    sign_in users(:two)
    get :show, :id => @post.id
    assert_response 403
  end
  
  test "should deny unauthenticated show post without random token" do
    sign_out users(:one)
    get :show, :id => @post.id
    assert_redirected_to new_user_session_path
  end
  
  test "should get edit" do
    get :edit, :id => @post.to_param
    assert_response :success
  end

  test "should update post" do
    put :update, :id => @post.to_param, :post => @post.attributes
    privlyDataURL = post_url @post, @post.data_url_parameters.merge(
      :format => "json")
    result = "#{request.protocol}#{request.host_with_port}/apps/" + 
      @post.privly_application + "/show?" + 
      @post.url_parameters.to_query + 
      "&privlyDataURL=" + ERB::Util.url_encode(privlyDataURL)
    assert_redirected_to result
  end
  
  test "should get CSV" do
    get :index, :format => :csv
    assert_response :success
  end
  
  test "should destroy all user posts" do
    post_count = users(:one).posts.count
    assert post_count > 0
    delete :destroy_all
    assert_redirected_to posts_path
    assert users(:one).posts.count == 0
    assert Post.all.count > 0
  end

  test "should destroy post" do
    assert_difference('Post.count', -1) do
      delete :destroy, :id => @post.id
    end
    assert_redirected_to posts_path
  end
  
  test "should get user account details" do
    get :user_account_data
    assert_response :success
  end
  
end
