class WelcomeController < ApplicationController
  
  skip_before_filter :redirect_to_alpha_domain
  
  def index
  end
  
end
