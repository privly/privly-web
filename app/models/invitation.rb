class Invitation < ActiveRecord::Base
  
  validates_uniqueness_of :email, :message => "must be unique."
  
  validates_format_of :email,
    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
    :message => 'must be valid'
  
  validate :not_a_user
  
  def not_a_user
    if User.find_by_email(email)
      errors.add(:email, "must be unique.")
    end
  end
  
  self.per_page = 100
  
end
