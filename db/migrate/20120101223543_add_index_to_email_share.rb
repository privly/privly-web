class AddIndexToEmailShare < ActiveRecord::Migration
  def change
    add_index :email_shares, :email
  end
end
