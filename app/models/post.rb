# Posts are the central storage endpoint for Privly content. They optionally
# store cleartext markdown content and serialized JSON of any schema. Currently
# two posting applications use the Post endpoint: ZeroBins push encrypted content
# to the serialized JSON storage, and Privly "posts" use the rendered Markdown
# storage.
class Post < ActiveRecord::Base
  
  belongs_to :user
  
  # Structured content is serialized JSON. The web application
  # never renders the structured content. It is intended to be used
  # by any injectable application.
  serialize :structured_content
  
  validates :privly_application, :presence => true, :format => { :with => /\A[a-zA-Z]+\z/,
      :message => "only allows letters" }
  
  before_create :generate_random_token
  
  validate :burn_after_in_future, :user_settings
  
  validates_inclusion_of :public, :in => [false, true]
  
  # The default number of records to display per page
  paginates_per 10
  
  # Posts cannot be saved with a burn after date set in the past.
  # Setting the burn after date to the past would cause the content
  # to be immediatly slotted for deletion.
  def burn_after_in_future
    if burn_after_date and burn_after_date < Time.now
      errors.add(:burn_after_date, 
      "#{burn_after_date} cannot be in the past, but you can destroy it now.")
    end
  end
  
  # Validate the length of time content that is associated with a user account
  # will be stored on the server before it is destroyed.
  def user_settings
    
    if user_id.nil? or not self.user.can_post
      errors.add(:burn_after_date, 
        "Your user account cannot create content.")
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
  
  # Give the URL for the Privly Application along with query parameters
  # for the required access tokens. This should only be called for users
  # who already have access to the content.
  def privly_URL
    
    privlyDataURL = Privly::Application.config.required_protocol +
      "://" +
      Privly::Application.config.link_domain_host +
      "/posts/" +
      self.id.to_s + 
      ".json"
      
    if self.random_token
      privlyDataURL += "?random_token=" + self.random_token
    end
      
    Privly::Application.config.required_protocol +
      "://" +
      Privly::Application.config.link_domain_host +
      "/apps/" + 
      self.privly_application + "/show?" + 
      self.url_parameters.to_query + 
      "&privlyDataURL=" + ERB::Util.url_encode(privlyDataURL)
  end
  
  # Get a hash of the injectable URL parameters.
  # Use this method to get the parameters for the post's URL helpers.
  # This is for legacy applications that don't specify their
  # injectable app.
  def deprecated_injectable_parameters
    
    injectable_application_name = "Unknown"
    
    if self.content
      injectable_application_name = "PlainPost"
    elsif self.structured_content
      injectable_application_name = "ZeroBin"
    end
    
    if self.burn_after_date
      sharing_url_parameters = {
        :privlyInjectableApplication => injectable_application_name,
        :random_token => self.random_token,
        :privlyBurntAfter => self.burn_after_date.to_i,
        :burntAfter => self.burn_after_date.to_i, # Deprecated
        :privlyInject1 => true, 
        :host => Privly::Application.config.link_domain_host,
        :port => nil}
      return sharing_url_parameters
    else
      sharing_url_parameters = {
        :privlyInjectableApplication => injectable_application_name,
        :random_token => self.random_token,
        :privlyInject1 => true, 
        :host => Privly::Application.config.link_domain_host,
        :port => nil}
      return sharing_url_parameters
    end
  end
  
  # Get the parameters for the non data URL parts of the model
  def url_parameters
    
    if self.burn_after_date
      sharing_url_parameters = {
        :privlyApp => self.privly_application,
        :random_token => self.random_token,
        :privlyInject1 => true}
    else
      sharing_url_parameters = {
        :privlyApp => self.privly_application,
        :random_token => self.random_token,
        :privlyInject1 => true}
    end
    
    return sharing_url_parameters
  end
  
  # Get the parameters intendended to be on the
  # data URL.
  def data_url_parameters
    parameters = {
      :random_token => self.random_token,
      :host => Privly::Application.config.link_domain_host,
      :port => nil}
    return parameters
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
