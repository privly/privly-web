class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    
    #owner can do anything to their post
    can :manage, Post, :user_id => user.id
    can :manage, EmailShare, :post => {:user_id => user.id}
    
    #if it is marked public
    can :read, Post, :public => true
    
    #email shares
    can :read, Post, :email_shares => {:email => user.email, :can_show => true} 
    can :destroy, Post, :email_shares => {:email => user.email, :can_destroy => true} 
    can :update, Post, :email_shares => {:email => user.email, :can_update => true}
    can :manage, EmailShare, :post => {:email_shares => {:email => user.email, :can_share => true}}
    can :share, Post, :email_shares => {:email => user.email, :can_share => true}
    
  end
end
