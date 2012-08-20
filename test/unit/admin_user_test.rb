require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  
  test "should create admin user" do
    admin_user = AdminUser.new
    admin_user.email = "user@email.com"
    admin_user.password = "password"
    admin_user.password_confirmation = "password"
    assert admin_user.save
  end
  
  test "should not create admin user" do
    admin_user = AdminUser.new
    admin_user.email = "user@email.com"
    admin_user.password = "password"
    admin_user.password_confirmation = "Password_doesnt_match"
    assert !admin_user.save
  end
  
end
