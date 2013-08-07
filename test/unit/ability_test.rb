require 'test_helper'

# Tests CanCAn's Ability
class AbilityTest < ActiveSupport::TestCase
  
  test "user can only destroy posts which he owns or has a share" do
    user = User.create!(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    ability = Ability.new(user)
    post = Post.new
    post.content = "content"
    post.privly_application = "PlainPost"
    post.user = user
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.valid?
    assert ability.can?(:destroy, post)
  end
  
  test "cannot perform any post action if not shared or owned" do
    ability = Ability.new(nil)
    post = Post.new
    post.content = "content"
    post.privly_application = "PlainPost"
    post.user = User.first
    post.public = true
    post.burn_after_date = Time.now + 1.hour
    post.random_token = "random_token_NOT"
    assert post.save
    assert ability.cannot?(:destroy, post)
    assert ability.cannot?(:update, post)
    assert ability.cannot?(:share, post)
    assert ability.cannot?(:show, post)
    
    post.user = nil
    assert post.save
    assert ability.cannot?(:destroy, post)
    assert ability.cannot?(:update, post)
    assert ability.cannot?(:share, post)
    assert ability.cannot?(:show, post)
  end
  
  test "cannot perform any post action without random token" do
    ability = Ability.new(nil)
    post = Post.new
    post.content = "content"
    post.privly_application = "PlainPost"
    post.public = true
    post.burn_after_date = Time.now + 1.hour
    post.random_token = "random_token_NOT"
    assert post.save
    assert ability.cannot?(:destroy, post)
    assert ability.cannot?(:update, post)
    assert ability.cannot?(:share, post)
    assert ability.cannot?(:show, post)
    post.user = nil
    assert ability.cannot(:destroy, post)
    assert ability.cannot(:update, post)
    assert ability.cannot(:share, post)
    assert ability.cannot(:show, post)
  end
  
  test "can only post to identity with posting permission" do
    user = User.new(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    user.can_post = true
    ability = Ability.new(user)
    assert ability.can?(:new, Post.new)
    
    post = Post.new
    post.content = "content"
    post.privly_application = "PlainPost"
    post.user = user
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.valid?
    assert ability.can?(:create, post)
    
    user.can_post = false
    ability = Ability.new(user)
    assert ability.cannot?(:create, post)
    
    ability = Ability.new(nil)
    assert ability.cannot?(:create, post)
  end
  
  test "can create share" do
    user = User.create!(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    ability = Ability.new(user)
    
    post = Post.first
    post.user = user
    assert post.save
    assert ability.can?(:update, post)
    
    share = Share.new({:post_id => 1,
      :identity => "email22@email.com",
      :can_show => true, :can_destroy => true, 
      :can_update => true, :can_share => true})
    share.identity_provider = IdentityProvider.find_by_name("Privly Verified Email")
    share.post_id = 1
    assert share.save
      
    assert ability.can?(:create, share)
  end
  
  test "can manage own post" do
    user = User.create!(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    user.can_post = true
    post = Post.new
    post.user = user
    ability = Ability.new(user)
    assert ability.can?(:show, post)
    assert ability.can?(:index, post)
    assert ability.can?(:edit, post)
    assert ability.can?(:new, post)
    assert ability.can?(:update, post)
    assert ability.can?(:destroy, post)
    assert ability.can?(:share, post)
    assert ability.can?(:create, post)
  end
  
  test "cannot manage another's post" do
    user = User.create!(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    user2 = User.create!(:email => "ability_test2@email.com",
      :password => "password", :password_confirmation => "password")
    user.can_post = true
    ability = Ability.new(user)
    post = Post.new
    post.user = user2
    assert ability.cannot?(:manage, post)
    assert ability.cannot?(:show, post)
    assert ability.cannot?(:index, post)
    assert ability.cannot?(:edit, post)
    # It will hit the anonymous posting endpoint
    assert ability.can?(:new, post)
    assert ability.cannot?(:update, post)
    assert ability.cannot?(:destroy, post)
    assert ability.cannot?(:share, post)
    assert ability.cannot?(:create, post)
  end
  
  
  test "cannot create share on another's post" do
    user = User.create!(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    ability = Ability.new(user)
    user2 = User.create!(:email => "ability_test2@email.com",
      :password => "password", :password_confirmation => "password")
    post = Post.new
    post.user = user2
    
    ability = Ability.new(user)
    assert ability.cannot?(:update, post)
    
    share = Share.new({:post_id => 1,
      :identity => "email22@email.com",
      :can_show => true, :can_destroy => true, 
      :can_update => true, :can_share => true})
    share.identity_provider = IdentityProvider.find_by_name("Privly Verified Email")
    share.post_id = 1
    
    assert ability.cannot?(:create, share)
  end
  
  test "can perform actions based on email share" do
    
    #Create the users
    user = User.create!(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    user_shared_with = User.create!(:email => "ability_test2@email.com",
      :password => "password", :password_confirmation => "password")
    
    #Create the post
    post = Post.new
    post.content = "content"
    post.privly_application = "PlainPost"
    post.user = user
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.valid?
    post.save
    
    # Create the share on the post
    share = Share.new({:post_id => 1,
      :identity => user_shared_with.email,
      :can_show => true, :can_destroy => true, 
      :can_update => true, :can_share => true})
    share.post_id = post.id
    share.identity_provider = IdentityProvider.find_by_name("Privly Verified Email")
    assert share.save
      
    assert_not_nil Share.find_by_post_id(post.id)
    share = Share.find_by_post_id(post.id)
    assert share.identity_pair == "#{share.identity_provider_id}:#{user_shared_with.email}"
    assert (not post.shares.find_by_can_show_and_identity_pair(true, ["#{share.identity_provider_id}:#{user_shared_with.email}"]).nil?)
    
    ability = Ability.new(user_shared_with, "127.0.0.1", post.random_token)
    assert ability.can?(:update, post)
    assert ability.can?(:show, post)
    assert ability.can?(:edit, post)
    assert ability.can?(:update, post)
    assert ability.can?(:destroy, post)
    assert ability.can?(:share, post)
    assert ability.can?(:new, post)
    assert ability.cannot?(:index, post)
    assert ability.cannot?(:create, post)
    
    share = Share.new({:post_id => 1,
      :identity => "email22@email.com",
      :can_show => true, :can_destroy => true, 
      :can_update => true, :can_share => true})
    share.identity_provider = IdentityProvider.find_by_name("Privly Verified Email")
    share.post_id = 1
    assert ability.cannot?(:create, share)
  end
  
  test "can perform actions based on domain share" do
    
    #Create the users
    user = User.new(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    assert user.save
    user_shared_with = User.new(:email => "ability_test2@email.com",
      :password => "password", :password_confirmation => "password")
    assert user_shared_with.save
    
    #Create the post
    post = Post.new
    post.content = "content"
    post.privly_application = "PlainPost"
    post.user = user
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.valid?
    post.save
    
    # Create the share on the post
    share = Share.new({:identity => user_shared_with.domain,
      :can_show => true, :can_destroy => true, 
      :can_update => true, :can_share => true})
    share.post_id = post.id
    share.identity_provider = IdentityProvider.find_by_name("Privly Verified Domain")
    assert user_shared_with.domain == "@email.com"
    assert share.save
      
    assert_not_nil Share.find_by_post_id(post.id)
    share = Share.find_by_post_id(post.id)
    assert share.identity_pair == "#{share.identity_provider_id}:#{user_shared_with.domain}"
    assert (not post.shares.find_by_can_show_and_identity_pair(true, ["#{share.identity_provider_id}:#{user_shared_with.domain}"]).nil?)
    
    ability = Ability.new(user_shared_with, "127.0.0.1", post.random_token)
    assert ability.can?(:update, post)
    assert ability.can?(:show, post)
    assert ability.can?(:edit, post)
    assert ability.can?(:update, post)
    assert ability.can?(:destroy, post)
    assert ability.can?(:share, post)
    assert ability.can?(:new, post)
    assert ability.cannot?(:index, post)
    assert ability.cannot?(:create, post)
    
  end
  
  test "can perform actions based on IP Address share" do
    
    #Create the users
    user = User.create!(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    user_shared_with = User.create!(:email => "ability_test2@email.com",
      :password => "password", :password_confirmation => "password")
    
    #Create the post
    post = Post.new
    post.content = "content"
    post.privly_application = "PlainPost"
    post.user = user
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.valid?
    post.save
    
    # Create the share on the post
    share = Share.new({:post_id => 1,
      :identity => "127.0.0.1",
      :can_show => true, :can_destroy => true, 
      :can_update => true, :can_share => true})
    share.post_id = post.id
    share.identity_provider = IdentityProvider.find_by_name("IP Address")
    assert share.save
      
    assert_not_nil Share.find_by_post_id(post.id)
    share = Share.find_by_post_id(post.id)
    assert share.identity_pair == "#{share.identity_provider_id}:127.0.0.1"
    assert (not post.shares.find_by_can_show_and_identity_pair(true, ["#{share.identity_provider_id}:127.0.0.1"]).nil?)
    
    ability = Ability.new(user_shared_with, "127.0.0.1", post.random_token)
    assert ability.can?(:update, post)
    assert ability.can?(:show, post)
    assert ability.can?(:edit, post)
    assert ability.can?(:update, post)
    assert ability.can?(:destroy, post)
    assert ability.can?(:share, post)
    assert ability.can?(:new, post)
    assert ability.cannot?(:index, post)
    assert ability.cannot?(:create, post)
    
  end
  
  test "cannot perform actions based on IP Address share without random_token" do
    
    #Create the users
    user = User.create!(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    user_shared_with = User.create!(:email => "ability_test2@email.com",
      :password => "password", :password_confirmation => "password")
    
    #Create the post
    post = Post.new
    post.content = "content"
    post.privly_application = "PlainPost"
    post.user = user
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.valid?
    post.save
    
    # Create the share on the post
    share = Share.new({:post_id => 1,
      :identity => "127.0.0.1",
      :can_show => true, :can_destroy => true, 
      :can_update => true, :can_share => true})
    share.post_id = post.id
    share.identity_provider = IdentityProvider.find_by_name("IP Address")
    assert share.save
      
    assert_not_nil Share.find_by_post_id(post.id)
    share = Share.find_by_post_id(post.id)
    assert share.identity_pair == "#{share.identity_provider_id}:127.0.0.1"
    assert (not post.shares.find_by_can_show_and_identity_pair(true, ["#{share.identity_provider_id}:127.0.0.1"]).nil?)
    
    ability = Ability.new(user_shared_with, "127.0.0.1")
    assert ability.cannot?(:update, post)
    assert ability.cannot?(:show, post)
    assert ability.cannot?(:edit, post)
    assert ability.cannot?(:update, post)
    assert ability.cannot?(:destroy, post)
    assert ability.cannot?(:share, post)
    assert ability.can?(:new, post)
    assert ability.cannot?(:index, post)
    assert ability.cannot?(:create, post)
    
  end
  
  test "cannot perform actions not on share" do
    
    #Create the users
    user = User.create!(:email => "ability_test@email.com",
      :password => "password", :password_confirmation => "password")
    user_shared_with = User.create!(:email => "ability_test2@email.com",
      :password => "password", :password_confirmation => "password")
    
    #Create the post
    post = Post.new
    post.content = "content"
    post.privly_application = "PlainPost"
    post.user = user
    post.burn_after_date = Time.now + 1.hour
    post.public = true
    assert post.valid?
    post.save
    
    # Create the share on the post
    share = Share.new({:post_id => 1,
      :identity => user_shared_with.email,
      :can_show => false, :can_destroy => false, 
      :can_update => false, :can_share => false})
    share.identity_provider = IdentityProvider.find_by_name("Privly Verified Email")
    share.post_id = post.id
    assert share.save
      
    assert_not_nil Share.find_by_post_id(post.id)
    share = Share.find_by_post_id(post.id)
    assert share.identity_pair == "#{share.identity_provider_id}:#{user_shared_with.email}"
    
    ability = Ability.new(user_shared_with)
    assert ability.cannot?(:update, post)
    assert ability.cannot?(:show, post)
    assert ability.cannot?(:edit, post)
    assert ability.can?(:new, post)
    assert ability.cannot?(:update, post)
    assert ability.cannot?(:destroy, post)
    assert ability.cannot?(:share, post)
    assert ability.cannot?(:index, post)
    assert ability.cannot?(:create, post)
    
  end
  
end
