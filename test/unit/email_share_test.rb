require 'test_helper'

class EmailShareTest < ActiveSupport::TestCase
  
  test "should not save EmailShare without a post" do
    email_share = EmailShare.new
    email_share.email = "validEmail@email.com"
    assert !email_share.save
  end
  
  test "should not save invalid email" do
    email_share = EmailShare.new
    email_share.post = Post.first
    email_share.email = "invalidEmail"
    assert !email_share.save
    assert(!email_share.valid?)
    
    email_share.email = "invalidEmail@"
    assert !email_share.save
    assert(!email_share.valid?)
    
    email_share.email = "@invalidEmail.com"
    assert !email_share.save
    assert(!email_share.valid?)
    
    email_share.email = "invalidEmail@.com"
    assert !email_share.save
    assert(!email_share.valid?)
    
    email_share.email = "invalidEmail@a.c"
    assert !email_share.save
    assert(!email_share.valid?)
    
  end
  
  test "should save email share" do
    email_share = EmailShare.new
    email_share.post = Post.first
    email_share.email = "validEmail@email.com"
    assert email_share.save
    
    email_share.email = "validEmail@email.ly"
    assert email_share.save
    
    email_share.email = "validEmail@email.tv"
    assert email_share.save
    
    email_share.email = "validEmail@email.customTLD"
    assert email_share.save
  end
  
  test "should not save email share without post" do
    email_share = EmailShare.new
    email_share.email = "validEmail@email.com"
    assert !email_share.save
    assert(!email_share.valid?)
  end
  
end
