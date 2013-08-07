# Pages are nearly static content and information. The pages controller
# primarily manages which panels are displayed in the sidebar and 
# authorizes the account page.
class PagesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:account]
  skip_before_filter :redirect_to_alpha_domain

  # == Get the privacy policy, disclosures, terms of service, and alerts
  # 
  # Returns the current legal and disclosure information
  #  
  # ==== Routing  
  #
  # +GET+: /pages/privacy
  #
  # ==== Formats  
  #  
  # * +html+
  #
  # ==== Parameters  
  # 
  # none
  #
  def privacy
    @sidebar = {:contribute => true}
  end

  # == Donation Information
  # 
  # Returns the current avenues for donation.
  #  
  # ==== Routing  
  #
  # +GET+: /pages/donate
  #
  # ==== Formats  
  #  
  # * +html+
  #
  # ==== Parameters  
  # 
  # none
  #
  def donate
    @sidebar = {:contribute => true}
  end

  # == Download Information
  # 
  # Returns information on the publicly available software.
  #  
  # ==== Routing  
  #
  # +GET+: /pages/download
  #
  # ==== Formats  
  #  
  # * +html+
  #
  # ==== Parameters  
  # 
  # none
  #
  def download
    @sidebar = {:contribute => true}
  end

  # == General Information
  # 
  # Returns the general information about the Privly Project
  #  
  # ==== Routing
  #
  # +GET+: /pages/about
  #
  # ==== Formats  
  #  
  # * +html+
  #
  # ==== Parameters  
  # 
  # none
  #
  def about
    @sidebar = {:about => true, :news => true, :in_the_news => true}
  end
  
  # == Kickstarter Information
  # 
  # Tells the user the Kickstarter is completed.
  #  
  # ==== Routing  
  #
  # +GET+: /pages/kickstarter
  #
  # ==== Formats  
  #  
  # * +html+
  #
  # ==== Parameters  
  # 
  # none
  #
  def kickstarter
    @sidebar = {:news => true, :about => true, :contribute => true}
  end
  
  # == Account Information
  # 
  # Returns information about the current user's account, including perks
  # offered by the Kickstarter and identity information.
  #  
  # ==== Routing  
  #
  # +GET+: /pages/account
  #
  # ==== Cookies
  #
  # User must be authenticated via a session cookie
  #
  # ==== Formats  
  #  
  # * +html+
  #
  # ==== Parameters  
  # 
  # none
  #
  def account
  end

end
