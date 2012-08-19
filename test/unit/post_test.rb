require 'test_helper'

class PostTest < ActiveSupport::TestCase
  
  test "should not save Post without content" do
    post = Post.new
    post.content = ""
    assert !post.save
  end
  
  test "should not save anonymous Post without burn after date" do
    post = Post.new
    post.content = "content"
    post.random_token = "notReallyRandom"
    assert !post.save
  end
  
  test "should save post" do
    post = Post.new
    post.content = "content"
    post.user = User.first
    assert post.save
    
    post = Post.new
    post.content = "content"
    post.random_token = "notReallyRandom"
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.save
    
    post = Post.new
    post.content = "content"
    post.burn_after_date = Time.now + 1.hour
    post.random_token = "notReallyRandom"
    post.public = true
    assert post.save
    
    post = Post.new
    post.user = User.first
    post.content = "content"
    post.burn_after_date = Time.now + 1.hour
    post.random_token = "notReallyRandom"
    post.public = true
    assert post.save
    
    post = Post.new
    post.public = true
    post.content = "content"
    post.burn_after_date = Time.now + 1.hour
    assert post.save
  end
  
end
