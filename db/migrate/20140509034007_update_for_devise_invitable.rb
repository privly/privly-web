class UpdateForDeviseInvitable < ActiveRecord::Migration
  def up
    add_column :users, :invitation_created_at, :datetime
    User.all.each do |user|
      user.invitation_created_at = user.invitation_sent_at
      user.save
    end
  end

  def down
    remove_column :users, :invitation_created_at
  end
end
