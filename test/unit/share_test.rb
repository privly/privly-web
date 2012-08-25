require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  
  test "should not save Share without a post" do
    share = Share.new
    share.identity_provider = IdentityProvider.first
    share.identity = "validEmail@email.com"
    assert !share.save
  end
  
  test "should not save invalid email" do
    share = Share.new
    share.identity_provider = IdentityProvider.find_by_name("Privly Verified Email")
    share.post = Post.first
    share.identity = "invalidEmail"
    assert !share.save
    assert(!share.valid?)
    
    share.identity = "invalidEmail@"
    assert !share.save
    assert(!share.valid?)
    
    share.identity = "@invalidEmail.com"
    assert !share.save
    assert(!share.valid?)
    
    share.identity = "invalidEmail@.ly"
    assert !share.save
    assert(!share.valid?)
    
    share.identity = "invalidEmail@a.c"
    assert !share.save
    assert(!share.valid?)
    
  end
  
  test "should save email share" do
    share = Share.new
    share.post = Post.first
    share.identity_provider = IdentityProvider.first
    share.identity = "validEmail@email.com"
    assert share.save
    
    share.identity = "validEmail@email.ly"
    assert share.save
    
    share.identity = "validEmail@email.tv"
    assert share.save
    
    share.identity = "validEmail@email.customTLD"
    assert share.save
  end
  
  test "should not save email share without post" do
    share = Share.new
    share.identity = "validEmail@email.com"
    share.identity_provider = IdentityProvider.first
    assert !share.save
    assert(!share.valid?)
  end
  
end
