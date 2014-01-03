# The welcome controller manages the front page of the website.
class WelcomeController < ApplicationController
  
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
    end
  end
  
end
