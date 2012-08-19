class Post < ActiveRecord::Base
  
  belongs_to :user
  
  has_many :email_shares, :dependent => :destroy
  
  before_create :generate_random_token
  
  validates :content, :presence => true
  
  validate :burnt_after_in_future, :unauthenticated_user_settings
  
  attr_accessible :content, :public, :burn_after_date, :random_token
  
  self.per_page = 5
  
  def burnt_after_in_future
    if burn_after_date and burn_after_date < Time.now
      errors.add(:burn_after_date, "#{burn_after_date}cannot be in the past, but you can destroy it now.")
    end
  end
  
  def unauthenticated_user_settings
    if user_id.nil?
      if not burn_after_date
        errors.add(:burn_after_date, "#{burn_after_date}must be specified for anonymous posts.")
      elsif burn_after_date > Time.now + 1.day
        errors.add(:burn_after_date, "#{burn_after_date}cannot be more than one day into the future.")
      end
      if not self.public
        errors.add(:public, "anonymous posts must be public.")
      end
    end
  end
  
  def generate_random_token
     #generates a random hex string of length 10
     unless self.random_token
       self.random_token = SecureRandom.hex(5)
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
