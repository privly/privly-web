#
# IdentityProvider gives the name and description of various forms of 
# identity respected by the system. When an identity is added to the share 
# table, it calls the formatters and validations found in this class, which 
# is necessary in some share types (like emails should be lowercase).
#
# Starting Providers are:
# "Privly Verified Email"
# "Privly Verified Domain"
# "Password"
# "IP Address"
#
class IdentityProvider < ActiveRecord::Base
  
  has_many :shares, :dependent => :destroy
  validates_presence_of :name, :description
  validates_uniqueness_of :name, :description
  
  # Mass assignment is not available
  attr_accessible
  
  # A regular expression to validate and determine share type as
  # an email share
  EMAIL_REGEXP = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  
  # A regular expression to validate and determine share type as
  # an domain share
  DOMAIN_REGEXP = /^@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  
  # A regular expression to validate and determine share type as
  # an IP Address share
  IP_ADDRESS_REGEXP = /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
  
  # Format the identity according to the requirements of the Identity Provider.
  # Most identity poviders either need the user input to be all lowercase, or
  # no formatting actions performed.
  def format_identity(identity)
    if self.name == "Privly Verified Email"
      identity.strip!
      identity.downcase!
      return identity
    elsif self.name == "Privly Verified Domain"
      identity.strip!
      identity.downcase!
      return identity
    elsif self.name == "Password"
      identity.strip!
      identity = BCrypt::Password.create(identity, :cost => 12) #about cost http://goo.gl/AKZWq
      return identity
    elsif self.name == "IP Address"
      identity.strip!
      return identity
    end
  end
  
  # Perform any identity-type validations on the identity.
  # This method returns an empty string if there are no errors,
  # otherwise it returns a string describing the nature of the
  # error.
  def validate_identity(identity)
    if self.name == "Privly Verified Email"
      return IdentityProvider.privly_email_validations(identity)
    elsif self.name == "Privly Verified Domain"
      return IdentityProvider.privly_domain_validations(identity)
    elsif self.name == "Password"
      return IdentityProvider.content_password_validations
    elsif self.name == "IP Address"
      return IdentityProvider.ip_address_validations(identity)
    end
  end
  
  class << self
    
    extend ActiveSupport::Memoizable
    
    # This function speeds calls to the identity
    # provider object by memoizing the result of the function.
    def identity_provider_memoizer(name)
      find_by_name(name)
    end
    memoize :identity_provider_memoizer

    def content_password_validations
      ""
    end
    
    #
    # Identity specific validations
    #

    # Make sure the email is recognized by the email regular expression.
    # Return an error message if the email does not match.
    def privly_email_validations(identity)
      if EMAIL_REGEXP.match(identity)
        return ""
      else
        return "the identity is not a proper email"
      end
    end

    # Make sure the email is recognized by the email regular expression.
    # Return an error message if the email does not match.
    def privly_domain_validations(identity)
      if DOMAIN_REGEXP.match(identity)
        return ""
      else
        return "the identity is not a proper domain"
      end
    end

    # Make sure the IP Address is recognized by the regular expression.
    # Return an error message if the IP Address does not match.
    def ip_address_validations(identity)
      if IP_ADDRESS_REGEXP.match(identity)
        return ""
      else
        return "the identity is not a proper IP Address"
      end
    end
    
    # Returns the identifier for the given identity by calling each validation
    # in turn until one passes.
    def identity_provider_from_identity(identity)
      if privly_email_validations(identity).empty?
        return IdentityProvider.find_by_name("Privly Verified Email")
      elsif privly_domain_validations(identity).empty?
        return IdentityProvider.find_by_name("Privly Verified Domain")
      elsif ip_address_validations(identity).empty?
        return IdentityProvider.find_by_name("IP Address")
      end
    end
    
  end
  
end
