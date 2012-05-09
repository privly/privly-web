class Post < ActiveRecord::Base
  belongs_to :user
  has_many :email_shares, :dependent => :destroy
  
  attr_accessible :content, :public, :burn_after_date
  
  validate :burnt_after_in_future
  
  self.per_page = 5
  
  def burnt_after_in_future
    if burn_after_date and burn_after_date < Time.now
      errors.add(:burn_after_date, "#{burn_after_date}cannot be in the past, but you can destroy it now.")
    end
  end
  
  #used by cron jobs to delete all the burnt posts
  class << self
     def destroy_burnt_posts
       posts_to_destroy = Post.find :all, :conditions => ['burn_after_date < ?', Time.now]
       for post in posts_to_destroy
         post.destroy
       end
     end
  end
  
end
