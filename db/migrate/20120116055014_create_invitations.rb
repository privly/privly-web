class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :email
      t.boolean :news

      t.timestamps
    end
    
    add_index :invitations, :email, {:unique => true}
    
    add_column :users, :admin, :boolean, :null => false, :default => 0
    
  end
end
