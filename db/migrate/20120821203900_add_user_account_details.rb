class AddUserAccountDetails < ActiveRecord::Migration
  def up
    add_column    :users, :alpha_invites, :integer, {:default => 0, :null => false}
    add_column    :users, :beta_invites, :integer, {:default => 0, :null => false}
    add_column    :users, :forever_account_value, :float, {:default => 0, :null => false}
    add_column    :users, :permissioned_requests_served, :float, {:default => 0, :null => false}
    add_column    :users, :nonpermissioned_requests_served, :float, {:default => 0, :null => false}
    add_column    :users, :can_post, :boolean, {:default => false, :null => false}
    add_column    :users, :wants_to_test, :boolean, {:default => false, :null => false}
    add_column    :users, :accepted_test_statement, :boolean, {:default => false, :null => false}
    add_column    :users, :notifications, :boolean, {:default => true, :null => false}

    # add_column(:users, :domain, :string, {:null => false, :default => ""}) unless User.column_names.include?('domain')

    User.all.each do |user|
      user.notifications = true

      # If they have a confirmed user account,
      # then they already wanted to test the sytem
      if user.confirmed_at
        user.can_post = true
        user.wants_to_test = true
        user.accepted_test_statement = false
        if not user.save
          user.destroy
          #raise "user #{user.email} would not save into the test group"
        end
      else
        user.can_post = false
        user.wants_to_test = false
        user.accepted_test_statement = false
        if not user.save
          user.destroy
          #raise "user #{user.email} would not save into the beta group"
        end
      end
    end
  end

  def down
    remove_column :users, :alpha_invites
    remove_column :users, :beta_invites
    remove_column :users, :forever_account_value
    remove_column :users, :permissioned_requests_served
    remove_column :users, :nonpermissioned_requests_served
    remove_column :users, :can_post
    remove_column :users, :wants_to_test
    remove_column :users, :accepted_test_statement
    remove_column :users, :notifications
  end
end
