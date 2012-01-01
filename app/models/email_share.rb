class EmailShare < ActiveRecord::Base
  
  belongs_to :post
  self.per_page = 100
  
  validates :email, :uniqueness => { :scope => :post_id,
      :message => "must be unique." }
  validates :post_id, :email, :presence => true
end
