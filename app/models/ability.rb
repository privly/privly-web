class Ability
  include CanCan::Ability
  
  def initialize(user, ip_address = "0.0.0.0", random_token = nil, content_password = nil)
    
    # Anyone can create ZeroBin content, but to view it you need the random_token
    can :create, ZeroBin
    can :show, ZeroBin, {:random_token => random_token}
    
    # Collect all the identities this user has
    identities = []
    
    # This should be refactored to remove the database call
    @privly_verified_email_id = IdentityProvider.find_by_name('Privly Verified Email').id
    @privly_verified_domain_id = IdentityProvider.find_by_name('Privly Verified Domain').id
    @password_id = IdentityProvider.find_by_name('Password').id
    @ip_address_id = IdentityProvider.find_by_name('IP Address').id
    if not content_password.nil?
      identities << "#{@password_id}:#{content_password}"
    end
    
    if not ip_address.nil?
      identities << "#{@ip_address_id}:#{ip_address}"
    end
    
    if not user.nil?
      
      # Add the user's email and domain identities
      identities << ["#{@privly_verified_email_id}:#{user.email}",
                    "#{@privly_verified_domain_id}:#{user.domain}"]
      
      # Users can manage their own content
      can [:show, :index, :edit, :new, :update, :destroy, :share], Post, {:user_id => user.id}
      can :manage, Share, :post => {:user_id => user.id}
      
      # The user account must have the posting permission
      can :create, Post, :user => user if user.can_post
    end
    
    user ||= User.new # guest user (not logged in)
    
    # If it is marked public and they have the random_token, they can read it
    can :show, Post, {:public => true, :random_token => random_token}
    
    # Anonymous posts are allowed (deprecated)
    can :create_anonymous, Post
    
    can :new, Post
    
    # Users can post anonymous content
    can :create, Post, {:user => nil} if !user.can_post
    
    #
    # Share management permitted by a share
    #
    can [:show, :edit, :create, :new, :update, :share, :destroy], Share do |share|
      not Share.find_by_can_share_and_post_id_and_identity_pair(true, share.post.id, identities).nil? and
        share.post.random_token == random_token
    end
    
    #
    # Post Actions permitted by Shares
    #
    can :show, Post, ["EXISTS (SELECT * FROM shares WHERE shares.post_id = posts.id AND shares.identity_pair IN (?) AND shares.can_show = true) AND posts.random_token = ?", identities, random_token] do |post|
      post.random_token == random_token and
        not post.shares.find_by_can_show_and_identity_pair(true, identities).nil?
    end
    
    can :destroy, Post, ["EXISTS (SELECT * FROM shares WHERE shares.post_id = posts.id AND shares.identity_pair IN (?) AND shares.can_destroy = true) AND posts.random_token = ?", identities, random_token] do |post|
      post.random_token == random_token and
        not post.shares.find_by_can_destroy_and_identity_pair(true, identities).nil?
    end
    
    can [:update, :edit], Post, ["EXISTS (SELECT * FROM shares WHERE shares.post_id = posts.id AND shares.identity_pair IN (?) AND shares.can_update = true) AND posts.random_token = ?", identities, random_token] do |post|
      post.random_token == random_token and
        not post.shares.find_by_can_update_and_identity_pair(true, identities).nil?
    end
    
    can :share, Post, ["EXISTS (SELECT * FROM shares WHERE shares.post_id = posts.id AND shares.identity_pair IN (?) AND shares.can_share = true) AND posts.random_token = ?", identities, random_token] do |post|
      post.random_token == random_token and
        not post.shares.find_by_can_share_and_identity_pair(true, identities).nil?
    end
    
  end
end
