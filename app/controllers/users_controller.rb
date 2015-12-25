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

  private

  def user_params
    if current_user.admin
      params.require(:person).permit(
        :alpha_invites, :beta_invites, :forever_account_value,
        :permissioned_requests_served, :nonpermissioned_requests_served,
        :can_post)
    else
      params.require(:person).permit(:email, :password, :password_confirmation, :remember_me)
    end
  end

end
