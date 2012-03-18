class WelcomeController < ApplicationController
  
  def index
    @sidebar = {:news => false}
  end
  
end
