class Ability
  include CanCan::Ability

  def initialize(user, random_token=nil)
    
    # Anyone can create ZeroBin content, but to view it you need the random_token
    can :create, ZeroBin
    can :show, ZeroBin, {:random_token => random_token}
    
    # Users can manage their own content
    if not user.nil?
      can [:show, :index, :edit, :new, :update, :destroy], Post, :user_id => user.id
      can :manage, EmailShare, :post => {:user_id => user.id}
      
      # The user account must have the posting permission
      can :create, Post, :user_id => user.id if user.can_post
    end
    
    user ||= User.new # guest user (not logged in)
    
    #if it is marked public and they have the random_token, they can read it
    can :show, Post, {:public => true, :random_token => random_token}
    can :create_anonymous, Post
    can :new, Post
    
    #email shares
    can :manage, EmailShare, :post => {:email_shares => {:email => user.email, :can_share => true}}
    
    can :show, Post, ["EXISTS (SELECT * FROM email_shares WHERE post_id = posts.id AND email = ? AND can_show = true)", user.email] do |post|
      EmailShare.find_by_can_show_and_post_id_and_email(true, post.id, user.email)
    end
    
    can :destroy, Post, ["EXISTS (SELECT * FROM email_shares WHERE post_id = posts.id AND email = ? AND can_destroy = true)", user.email] do |post|
      EmailShare.find_by_can_destroy_and_post_id_and_email(true, post.id, user.email)
    end
    
    can :update, Post, ["EXISTS (SELECT * FROM email_shares WHERE post_id = posts.id AND email = ? AND can_update = true)", user.email] do |post|
      EmailShare.find_by_can_update_and_post_id_and_email(true, post.id, user.email)
    end
    
    can :share, Post, ["EXISTS (SELECT * FROM email_shares WHERE post_id = posts.id AND email = ? AND can_share = true)", user.email] do |post|
      EmailShare.find_by_can_share_and_post_id_and_email(true, post.id, user.email)
    end
    
  end
end
