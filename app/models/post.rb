class Post < ActiveRecord::Base
  
  belongs_to :user
  
  # Structured content is serialized JSON. The web application
  # never renders the structured content. It is intended to be used
  # by any injectable application.
  serialize :structured_content
  
  has_many :shares, :dependent => :destroy
  
  before_create :generate_random_token
  
  validate :burn_after_in_future, :unauthenticated_user_settings,
    :authenticated_user_settings
  
  validates_inclusion_of :public, :in => [false, true]
  
  attr_accessible :content, :structured_content
  
  # The default number of records to display per page
  paginates_per 10
  
  # Posts cannot be saved with a burn after date set in the past.
  # Setting the burn after date to the past would cause the content
  # to be immediatly slotted for deletion.
  def burn_after_in_future
    if burn_after_date and burn_after_date < Time.now
      errors.add(:burn_after_date, "#{burn_after_date} cannot be in the past, but you can destroy it now.")
    end
  end
  
  # Set the length of time content that is not associated with a user account
  # will be stored before it is destroyed.
  # All anonymous posts will be destroyed within two days.
  def unauthenticated_user_settings
    if user_id.nil? or not self.user.can_post
      if not burn_after_date
        errors.add(:burn_after_date, "#{burn_after_date} must be specified for anonymous posts.")
      elsif burn_after_date > Time.now + 2.day
        errors.add(:burn_after_date, "#{burn_after_date} cannot be more than two days into the future.")
      end
    end
  end
  
  # Set the length of time content that is associated with a user account
  # will be stored on the server before it is destroyed.
  # All posts will be destroyed within two weeks.
  def authenticated_user_settings
    if not user_id.nil? and self.user.can_post
      if not burn_after_date
        errors.add(:burn_after_date, "#{burn_after_date} must be specified.")
      elsif burn_after_date > Time.now + 15.days
        errors.add(:burn_after_date, "#{burn_after_date} cannot be more than two weeks into the future.")
      end
    end
  end
  
  # Generate a random token for controlling access to the content.
  # This token can be expired in the future, but when present, the content
  # cannot be accessed by users other than the owner without it. The purpose
  # behind the random token is to make link discovery a requirement for 
  # accessing the content.
  def generate_random_token
     #generates a random hex string of length 5
     unless self.random_token
       self.random_token = SecureRandom.hex(5)
     end
  end
  
  # Add shares to the current post from a comma and space separated list of
  # values. The share defualts to viewing permission, but any level of
  # permission can be generated.
  #
  # Returns an array of successfully created shares, or an empty array.
  def add_shares_from_csv(csv, can_show = true, can_update = false, 
    can_destroy = false, can_share = false)
    
    created_shares = []
    
    values = csv.split(/,| /)
    values.each do |value|
      if value and value.length > 0
        share = Share.new
        share.can_show = can_show
        share.can_update = can_update
        share.can_destroy = can_destroy
        share.can_share = can_share
        share.identity = value
        share.identity_provider = 
          IdentityProvider.identity_provider_from_identity(value)
        share.post = self
        if share.save
          created_shares << share
        end
      end
    end
    
    return created_shares
    
  end
  
  class << self
    
    # Used by cron jobs to delete all the burnt posts. Call it on the Post model,
    # Post.destroy_burnt_posts, to clear out all the posts which expired.
    def destroy_burnt_posts
      posts_to_destroy = Post.find :all, :conditions => ['burn_after_date < ?', Time.now]
      for post in posts_to_destroy
        post.destroy
      end
    end
    
  end
  
end
