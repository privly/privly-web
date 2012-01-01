class AddPublicToPost < ActiveRecord::Migration
  def change
    add_column :posts, :public, :boolean, :null => false, :default => 0
  end
end
