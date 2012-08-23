class DowncaseUserEmails < ActiveRecord::Migration
  def change
    User.all.each do |user|
      if user.email.include?("@")
        user.email.downcase!
        user.save
      else
        user.destroy
      end
    end
  end
end
