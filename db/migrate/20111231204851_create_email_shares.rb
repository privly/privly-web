class CreateEmailShares < ActiveRecord::Migration
  def change
    create_table :email_shares do |t|
      t.integer :post_id, :null => false
      t.string :email, :null => false

      t.boolean :can_show, :null => false, :default => 1
      t.boolean :can_destroy, :null => false, :default => 0
      t.boolean :can_update, :null => false, :default => 0
      t.boolean :can_share, :null => false, :default => 0
      
      t.timestamps
    end
  end
end
