class Post < ActiveRecord::Base
  belongs_to :user
  has_many :email_shares, :dependent => :destroy
  
  attr_accessible :content, :public
  
  self.per_page = 5
end
