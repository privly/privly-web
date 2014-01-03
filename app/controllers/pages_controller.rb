# Pages are nearly static content and information. The pages controller
# primarily manages which panels are displayed in the sidebar and 
# authorizes the account page.
class PagesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:account]

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
