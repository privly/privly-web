class AddUsersToPosts < ActiveRecord::Migration
  def change
    add_column :posts,  :user_id, :int
  end
end
