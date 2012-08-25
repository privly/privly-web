class IdentityProvider < ActiveRecord::Base
  
  has_many :shares, :dependent => :destroy
  validates_presence_of :name, :description
  validates_uniqueness_of :name, :description
  
  attr_accessible
  
  def privly_email_validations(identity)
    if identity.include?("@") and identity.index("@") > 0 and
      (identity.length - identity.index("@")) > 4
      return ""
    else
      return "the identity must be an email"
    end
  end
  
  # Perform any identity-type actions on the identifier
  def processed_identity(identity)
    identity.downcase!
    return identity
  end
  
  # Perform any identity-type validations on the identifier
  def validate_identity(identity)
    if self.name == "Privly Verified Email"
      return privly_email_validations(identity)
    else
      return ""
    end
  end
  
end
