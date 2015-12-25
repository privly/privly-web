# Invitations are sent by administrators after approving the user account or
# by users who have invitations remaining on their user account.
# User accounts are automatically created by the server when a person signs
# up for an invitation, but the activation link is not sent.
#
class Users::InvitationsController < Devise::InvitationsController
  
  before_filter :authenticate_admin_user!, 
   :except => [:create, :new, :use_invite]
  
  before_filter :authenticate_user!, :only => [:use_invite]
  
  # == Create a pending invitation.
  #
  # Create a user account for the email address supplied, but do not
  # supply them with the activation link unless 
  # Privly::Application.config.send_invitations is set to true in the
  # environment config.
  #
  # === Routing  
  #
  # POST /user/invitation
  #
  # === Formats  
  #  
  # * +html+
  #
  # === Parameters  
  #
  # <b>user [email]</b> - _string_ - Required
  # * Values: valid email address
  # * Default: nil
  # The email of the new user account
  def create
    
    if not params[:user] or not params[:user][:email]
      return
    end
        
    email = params[:user][:email]
    
    # Make sure it is not creating a duplicate user
    email.downcase!
    if User.where(:email => email).count == 0
      self.resource = resource_class.invite!(params[resource_name], current_inviter) do |u|
        u.email = email

        # Don't send the invitation
        if Privly::Application.config.send_invitations
          u.pending_invitation = false
          u.can_post = true
        else
          u.skip_invitation = true
          u.pending_invitation = true
        end
      end

      if resource.errors.empty? and not Privly::Application.config.send_invitations
        Notifier.pending_invitation(
          User.find_by email: email
        ).deliver_now # sends the email
      end
    end

    respond_to do |format|
      format.json {
        return render :json => {:success => true}
      }
      format.any {
        redirect_to welcome_path,
          :notice => "Thanks " + email +
            "! When we are ready for more users we will send you a message."
      }
    end
  end
  
  # == A user is using one of their invitations
  #
  # Create a user account for the email address supplied, and send the
  # activation link. Also use up an invitation credit.
  #
  # === Routing  
  #
  # POST /user/use_invite
  #
  # === Formats  
  #  
  # * +html+
  #
  # === Parameters  
  #
  # <b>user [email]</b> - _string_ - Required
  # * Values: valid email address
  # * Default: nil
  # The email of the new user account
  def use_invite
    
    # Make sure the user has invites remaining
    if current_user.alpha_invites < 1
      redirect_to pages_account_path, :notice => "You do not have any invitations at this time."
      return
    end
    
    # Invite existing user
    email = params[:user][:email]
    email.downcase!
    user = User.find_by_email(email)
    if user and user.pending_invitation
      user.can_post = true
      user.pending_invitation = false
      user.save
      user.invite!
      current_user.alpha_invites -= 1
      current_user.save
    end
    
    # Create a new user
    unless user
      self.resource = resource_class.invite!(params[resource_name], current_inviter) do |u|
        u.email = email
        u.can_post = true
        u.pending_invitation = false
      end
      if resource.errors.empty?
        current_user.alpha_invites -= 1
        current_user.save
      end
    end
    redirect_to pages_account_path, :notice => "We emailed " + email + " with an invitation."
  end
  
  # == Activate an account.
  #
  # Activate an account and invite the user to use it.
  # The user account must not be currently active. The
  # account is granted posting permission. Only ActiveAdmin
  # users have permission for this action.
  #  
  # === Routing  
  #
  # POST /users/invitations/send_invitation
  #
  # === Formats  
  #  
  # * +html+
  #
  # === Parameters  
  #
  # <b>user [id]</b> - _integer_ - Required
  # * Values: 1 to 9999999
  # * Default: nil
  # The ID of the user to be invited to the system.
  def send_invitation
    
    # check whether the user is admin or has invitations remaining
    
    user = User.find_by_id(params[:user][:id])
    
    if not user.pending_invitation or not user.confirmation_sent_at.nil?
      redirect_to admin_users_path, :notice => 'That user is already pending an account.'
    else
      user.can_post = true
      user.pending_invitation = false
      user.save
      user.invite!
      redirect_to admin_users_path, :notice => 'Invitation was sent.'
    end
    
  end
  
  # == Send an Update Email
  #
  # Send an email defined in app/view/notifier/update.html.erb.
  # Before sending this email you should change the update email text,
  # and add an email for plain text.
  #  
  # === Routing  
  #
  # POST /users/invitations/send_update
  #
  # === Formats  
  #  
  # * +html+
  #
  # === Parameters  
  #
  # <b>user [id]</b> - _integer_ - Required
  # * Values: 1 to 9999999
  # * Default: nil
  # The ID of the user to send the email.
  def send_update
    
    user = User.find_by_id(params[:user][:id])
    
    if not user.pending_invitation or not user.confirmation_sent_at.nil?
      redirect_to admin_users_path, :notice => 'That user is already pending an account.'
    else
      Notifier.update(user).deliver_now # sends the email
      redirect_to admin_users_path, :notice => 'You updated the user.'
    end
    
  end
end
