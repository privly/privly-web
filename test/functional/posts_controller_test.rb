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
    assert_response :success
    assert_not_nil assigns(:posts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create post" do
    
    sign_in  users(:one)
    
    assert_difference('Post.count') do
      post :create, :post => {:content => "Test Post 1", :public => true, 
        :burn_after_date => Time.now + 1.hour}
    end

    assert_redirected_to post_path(assigns(:post), 
      {:burntAfter => assigns(:post).burn_after_date.to_i,
        :privlyInject1 => true,
        :random_token => assigns(:post).random_token})
  end

  test "should show post" do
    
    get :show, :id => @post.to_param
    assert_response :success
    
    get :show, :id => @post.to_param, :format => "json"
    assert_response :success
    
    get :show, :id => @post.to_param, :format => "iframe"
    assert_response :success
    
  end
  
  test "should deny show post" do
    
    sign_out users(:one)
    
    get :show, :id => @post.id
    assert_redirected_to new_user_session_path
    
    get :show, {:id => @post.id, :format => "json"}
    error = JSON.parse(@response.body)
    assert error["error"] == "No access or it does not exist. You might have access to this if you login."
    
    get :show, :id => @post.id, :format => "iframe"
    assert_template "login"
    
  end
  
  test "should be burnt post" do
    
    @post = posts(:burnt)
    
    get :show, :id => @post.id
    assert_template "posts/noaccess"
    
    get :show, {:id => @post.id, :format => "json"}
    error = JSON.parse(@response.body)
    assert error["error"] == "You do not have access or it doesn't exist."
    
    get :show, :id => @post.id, :format => "iframe"
    assert_template "posts/noaccess"
    
  end

  test "should show post without random token" do
    
    sign_out users(:one)
    
    @post = posts(:two)
    
    get :show, :id => @post.to_param
    assert_redirected_to post_path(assigns(:post), 
      {:burntAfter => @post.burn_after_date.to_i, :privlyInject1 => true})
  end
  
  test "should deny post without random token" do
    
    sign_out users(:one)
        
    get :show, :id => @post.id
    assert_redirected_to new_user_session_path
    
    sign_in users(:two)
    
    get :show, :id => @post.id
    assert_redirected_to new_user_session_path
    
  end

  test "should get edit" do
    get :edit, :id => @post.to_param
    assert_response :success
  end

  test "should update post" do
    put :update, :id => @post.to_param, :post => @post.attributes
    assert_redirected_to post_path(assigns(:post))
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
end
