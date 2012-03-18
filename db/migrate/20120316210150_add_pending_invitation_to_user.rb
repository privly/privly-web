class AddPendingInvitationToUser < ActiveRecord::Migration
  def change
    add_column :users, :pending_invitation, :boolean, :null => false, :default => 0
  end
end
