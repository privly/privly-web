class DropShares < ActiveRecord::Migration
  def up
    drop_table :shares
    drop_table :identity_providers
  end

  def down
    create_table :identity_providers do |t|        
      t.string :name
      t.string :description
      t.timestamps
    end
    create_table :shares do |t|        
      t.integer :post_id
      t.integer :identity_provider_id
      t.string :identity
      t.string :identity_pair
      t.boolean :can_destroy
      t.boolean :can_update
      t.boolean :can_share
      t.boolean :can_share
      t.timestamps
    end
  end
end
