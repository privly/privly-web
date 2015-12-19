#
# AdminUser is the Devise managed user model for administering the application. All users in this model
# must be manually created in the console, or via an administrative interface.
#
class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable
end
