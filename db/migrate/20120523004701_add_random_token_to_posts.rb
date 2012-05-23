class AddRandomTokenToPosts < ActiveRecord::Migration
  def change
    
    add_column :posts, :random_token, :string
    
  end
end
