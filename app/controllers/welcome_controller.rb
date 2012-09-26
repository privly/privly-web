# The welcome controller manages the front page of the website.
class WelcomeController < ApplicationController
  
  skip_before_filter :redirect_to_alpha_domain
  
  # == Get the Root of the Site
  # 
  # This is the web application's landing page
  #  
  # ==== Routing  
  #
  # +GET+: /posts
  #
  # ==== Formats  
  #  
  # * +html+
  #
  # ==== Parameters  
  # 
  # None
  #
  def index
    respond_to do |format|
      format.html { render }
      format.iframe { render }
    end
  end
  
end
