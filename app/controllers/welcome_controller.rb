class WelcomeController < ApplicationController
  
  def index
    @sidebar = {:news => false}
    @invitation = Invitation.new
  end
  
end
