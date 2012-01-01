class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :manage, Post, :user_id => user.id
    can :manage, EmailShare, :post => {:user_id => user.id}
  end
end
