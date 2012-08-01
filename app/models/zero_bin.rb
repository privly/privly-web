class ZeroBin < ActiveRecord::Base
  
  # Don't allow any mass assignment
  attr_accessible
  
  # Random token will be required to view the content
  before_create :generate_random_token
  
  # Validations
  validates_presence_of :burn_after_date
  validate :burnt_after_within_next_day
  validates_length_of :iv, :minimum => 1, :maximum => 50, 
    :allow_blank => false
  validates_length_of :salt, :minimum => 1, :maximum => 50, 
    :allow_blank => false
  validates_length_of :ct, :minimum => 1, :allow_blank => false
  
  # Require the burnt_after_date to be in the future. The burnt_after_date
  # determines when the record should be destroyed on the server
  def burnt_after_within_next_day
    if burn_after_date and burn_after_date < Time.now
      errors.add(:burn_after_date, 
        "#{burn_after_date}must be in the next day.")
    end
  end
  
  # Require burn_after_date to be in the next 24 hours
  def unauthenticated_user_settings
    if burn_after_date > Time.now + 1.day or burn_after_date < Time.now
      errors.add(:burn_after_date, 
        "#{burn_after_date}must be in the next 24 hours.")
    end
  end
  
  # Generate and assign a random access token for use in authorization
  def generate_random_token
     #generates a random hex string of length 10
     unless self.random_token
       self.random_token = SecureRandom.hex(5)
     end
  end
  
  # Used by cron jobs to delete all the burnt Zero_bins
  class << self
     def destroy_burnt_zero_bins
       zero_bins_to_destroy = ZeroBin.find :all, 
         :conditions => ['burn_after_date < ?', Time.now]
       for zero_bin in zero_bins_to_destroy
         zero_bin.destroy
       end
     end
  end
  
end
