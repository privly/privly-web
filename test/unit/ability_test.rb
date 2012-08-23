require 'test_helper'

# Tests CanCAn's Ability
class AbilityTest < ActiveSupport::TestCase
  
  test "user can only destroy posts which he owns or has an email share" do
    user = User.create!(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    ability = Ability.new(user)
    post = Post.new
    post.content = "content"
    post.user = user
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.valid?
    assert ability.can?(:destroy, post)
    assert ability.cannot?(:destroy, Post.new)
  end
  
  test "can only post to identity with posting permission" do
    user = User.new(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    user.can_post = true
    ability = Ability.new(user)
    assert ability.can?(:new, Post.new)
    
    post = Post.new
    post.content = "content"
    post.user = user
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.valid?
    assert ability.can?(:create, post)
    
    user.can_post = false
    ability = Ability.new(user)
    assert ability.cannot?(:create, post)
    assert ability.can?(:create_anonymous, post)
    
    ability = Ability.new(nil)
    assert ability.cannot?(:create, post)
    assert ability.can?(:create_anonymous, post)
  end
  
  test "can create anonymous" do
    post = Post.new
    post.content = "content"
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.valid?
    ability = Ability.new(nil)
    assert ability.can?(:create_anonymous, post)
    assert ability.can?(:create, ZeroBin.new)
  end
  
end
