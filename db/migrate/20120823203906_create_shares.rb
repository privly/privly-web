class CreateShares < ActiveRecord::Migration
  def change
    
    create_table :identity_providers do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
    
    # Generic Shares table has column
    # for (identity_provider):(identity) so that
    # CanCan can easily manage permissions
    create_table :shares do |t|
      t.integer :post_id
      t.integer :identity_provider_id
      t.string :identity
      t.string :identity_pair
      t.boolean :can_show
      t.boolean :can_destroy
      t.boolean :can_update
      t.boolean :can_share
      
      t.timestamps
      
    end
    
    #These are the first forms of identity we are going to implement
    #since they are immediatly available in the request
    identity_provider = IdentityProvider.new
    identity_provider.name = "Privly Verified Email"
    identity_provider.description =
      "The Privly Verified email is the email for the Privly user's account. " +
      "Users must verify their email ownership with Privly"
    identity_provider.save
  
    identity_provider = IdentityProvider.new
    identity_provider.name = "Privly Verified Domain"
    identity_provider.description =
      "The Privly Verified Domain is the domain of the user's" +
      "Privly email address"
    identity_provider.save
      
    identity_provider = IdentityProvider.new
    identity_provider.name = "Password"
    identity_provider.description =
      "The password is a secret that when sent with the request" +
      "will add permissions on the content"
    identity_provider.save
    
    identity_provider = IdentityProvider.new
    identity_provider.name = "IP Address"
    identity_provider.description =
      "The IP address is where Privly requests originate"
    identity_provider.save
    
    # Move the old email shares into the new generic share table
    EmailShare.all.each do |email_share|
      share = Share.new
      share.post = email_share.post
      share.identity_provider = IdentityProvider.find_by_name("Privly Verified Email")
      email_share.email.downcase!
      share.identity = email_share.email
      share.can_show = email_share.can_show
      share.can_destroy = email_share.can_destroy
      share.can_update = email_share.can_update
      share.can_share = email_share.can_share
      share.identity_pair =  "#{IdentityProvider.find_by_name("Privly Verified Email").id}:#{share.identity}"
      share.save
    end
    
    drop_table :email_shares
    
    # this should be the only attribute we regularly search for
    add_index :shares, :identity_pair
    
  end
end
