class EmailShare < ActiveRecord::Base
  
  belongs_to :post
  self.per_page = 100
  
  validates :email, :uniqueness => { :scope => :post_id,
      :message => "must be unique." }
  validates :post_id, :email, :presence => true
  
  #effectively protects timestamps, access to email share is controlled by CanCan
  attr_accessible :post_id, :email, :can_show, :can_destroy, :can_update, :can_share

end
