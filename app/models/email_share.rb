class EmailShare < ActiveRecord::Base
  
  belongs_to :post
  paginates_per 100
  
  before_create :downcase_email
  
  validates :email, :uniqueness => { :scope => :post_id,
      :message => "must be unique." }
      
  validates :post_id, :email, :presence => true
  
  validates :email,
            :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  
  #effectively protects timestamps, access to email share is controlled by CanCan
  attr_accessible :post_id, :email, :can_show, :can_destroy, :can_update, :can_share
  
  def downcase_email
    self.email.downcase!
  end
  
end
