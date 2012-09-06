class DestroyDefaultAdminUser < ActiveRecord::Migration
  def up
    AdminUser.find_by_email('admin@example.com').destroy
  end

  def down
    AdminUser.create!(:email => 'admin@example.com', :password => 'password', :password_confirmation => 'password')
  end
end
