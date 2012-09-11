class AddDomainToUser < ActiveRecord::Migration
  def up
    
    add_column(:users, :domain, :string, {:null => false}) unless User.column_names.include?('domain')
    
    User.all.each do |user|
      user.domain = "@#{user.email.split("@")[1]}"
      user.save
    end
    
    add_index     :users, [:domain]
  end
  
  def down
    remove_index :user, [:domain]
    remove_column :users, :domain
  end
end
