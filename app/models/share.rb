class Share < ActiveRecord::Base
  
  belongs_to :identity_provider
  belongs_to :post
  
  validates_presence_of :identity_provider_id, :identity, :post_id
  
  validates_uniqueness_of :identity_pair, :scope => :post_id
  
  validate :identity_validations
  
  before_save :process_identity, :write_identity_pair
  
  attr_accessible :identity, :can_show, 
    :can_destroy, :can_update, :can_share, :post_id
  
  # Save the identity type and value into a single record to speed up queries
  def write_identity_pair
    self.identity_pair = "#{self.identity_provider_id}:#{self.identity}"
  end
  
  # Perform any identity-type actions on the identifier
  def process_identity
    self.identity = self.identity_provider.processed_identity(self.identity)
  end
  
  # Perform any identity-type validations on the identifier
  def identity_validations
    message = self.identity_provider.validate_identity(self.identity)
    if message
      errors.add(:identity, message)
    end
  end
  
end
