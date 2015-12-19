#
# User is the Devise managed user model for the application.
#
class User < ActiveRecord::Base
  
  has_many :posts, :dependent => :destroy
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, 
  # :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, 
         :validatable, 
         :confirmable, :lockable, :timeoutable, :validate_on_invite => true
  
  before_create :process_email
  
  before_validation :process_email
  
  validates :email,
           :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  
  validates :domain,
            :format => { :with => /\A@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  
  validates :authentication_token, :uniqueness => true, :allow_nil => true
  
  # Downcase the email and store the email's domain in a separate
  # column.
  def process_email
    if self.email.nil?
      return
    end
    self.email.downcase!
    domain = self.email.split("@")[1]
    if domain
      self.domain = "@" + domain
    end
  end
  
  before_save do
    if not self.platform.nil?
      self.platform = self.platform.downcase.strip
    end
  end
  
  #prevents users from getting account access via
  #invitation system
  #https://github.com/scambra/devise_invitable/wiki/Disabling-devise-recoverable,-if-invitation-was-not-accepted
  def send_reset_password_instructions
    super if invitation_token.nil?
  end
  
  def reset_authentication_token!
    self.authentication_token = SecureRandom.hex(16).to_i(16).to_s(36)
  end
  
end
