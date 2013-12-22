class AddTestingToUser < ActiveRecord::Migration
  def up
    add_column :users, :wants_to_test, :boolean, {:default => false, :null => false}
    add_column :users, :platform, :string
  end

  def down
    remove_column :users, :wants_to_test
    remove_column :users, :platform
  end
end
