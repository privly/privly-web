# == User Controller
#
# The user controller is largely managed by Devise. However,
# we permit users to destroy their account--along with all 
# their data (logs should be purged periodically as well)
#
class UsersController < ApplicationController
  
  # == Destroy a user.
  #
  # Users can only do this to themselves.
  #
  # === Routing  
  #
  # DELETE /user/:id
  #
  # === Formats  
  #  
  # * +html+
  def destroy
    if current_user
      current_user.destroy
      redirect_to welcome_path, :notice => 'User account destroyed.'
    else
      redirect_to welcome_path, :notice => 'You are not logged in.'
    end
  end
  
end
