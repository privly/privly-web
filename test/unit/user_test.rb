require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should not save user without a valid email" do
    user = User.new
    user.password = "password"
    user.password_confirmation = "password"
    assert !user.save
    
    user = User.new
    user.email = ""
    user.password = "password"
    user.password_confirmation = "password"
    assert !user.save
    
    user = User.new
    user.email = "badEmail"
    user.password = "password"
    user.password_confirmation = "password"
    assert !user.save
    
    user = User.new
    user.email = "badEmail@"
    user.password = "password"
    user.password_confirmation = "password"
    assert !user.save
    
    user = User.new
    user.email = "@badEmail"
    user.password = "password"
    user.password_confirmation = "password"
    assert !user.save
    
    user = User.new
    user.email = "badUser@badEmail"
    user.password = "password"
    user.password_confirmation = "password"
    assert !user.save
    
    user = User.new
    user.email = "@badEmail.com"
    user.password = "password"
    user.password_confirmation = "password"
    assert !user.save
    
    user = User.new
    assert !user.save
  end
  
  test "should save User" do
    user = User.new
    user.email = "user@email.com"
    user.password = "password"
    user.password_confirmation = "password"
    assert user.save
    
    user = User.new
    user.email = "user@email.com.ly"
    user.password = "password"
    user.password_confirmation = "password"
    assert user.save
  end
  
  test "user domain should be set" do
    user = User.new
    user.email = "user@email.com"
    user.password = "password"
    user.password_confirmation = "password"
    assert user.save
    assert user.domain == "@email.com"
    
    user = User.new
    user.email = "user@email.com.ly"
    user.password = "password"
    user.password_confirmation = "password"
    assert user.save
    assert user.domain == "@email.com.ly"
  end
  
end
