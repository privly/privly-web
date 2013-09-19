class CleanupUserTable < ActiveRecord::Migration
  def up
    remove_column :users, :admin
    remove_column :users, :wants_to_test
    remove_column :users, :accepted_test_statement
  end

  def down
    add_column :users, :admin, :boolean, :null => false, :default => 0
    add_column :users, :wants_to_test, :boolean, {:default => false, :null => false}
    add_column :users, :accepted_test_statement, :boolean, {:default => false, :null => false}
  end
end
