class User < ActiveRecord::Base
  
  has_many :authentications, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :token_authenticatable, 
         :confirmable, :lockable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  #prevents users from getting account access via
  #invitation system
  #https://github.com/scambra/devise_invitable/wiki/Disabling-devise-recoverable,-if-invitation-was-not-accepted
  def send_reset_password_instructions
    super if invitation_token.nil?
  end
  
  def self.find_for_oauth(provider, uid, email)

    if user = User.find_by_email(email)
      user
    else # Create a user with a stub password. 
      user = User.create!(:email => email, :password => Devise.friendly_token[0,20]) 
    end
    
    user.authentications.find_or_create_by_provider({:provider => provider, :uid => uid})
    
    user
  end
  
  #def self.new_with_session(params, session)
  #  super.tap do |user|
  #    if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
  #      user.email = data["email"]
  #    end
  #  end
  #end
  
end
