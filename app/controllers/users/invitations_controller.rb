# Invitations are sent by administrators after approving the user account.
# User accounts are automatically created by the server when a person signs
# up for an invitation, but the activation link is not sent.
#
class Users::InvitationsController < Devise::InvitationsController
  
  before_filter :authenticate_admin_user!, :except => [:create, :new]
  
  # == Create a pending invitation.
  #
  # Create a user account for the email address supplied, but do not
  # supply them with the activation link.
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
    
    #obscure whether the user account is already on the system
    if params[:user] and params[:user][:email]
      email = params[:user][:email]
      email.downcase!
      if User.where(:email => email).count > 0
        set_flash_message :notice, :send_instructions, :email => email
        redirect_to pages_about_path
        return
      end
    end
    
    self.resource = resource_class.invite!(params[resource_name], current_inviter) do |u|
      u.skip_invitation = true
      u.pending_invitation = true
    end
    
    if resource.errors.empty?
      set_flash_message :notice, :send_instructions, :email => self.resource.email
      respond_with resource, :location => after_invite_path_for(resource)
    else
      respond_with_navigational(resource) { render :new }
    end
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
      Notifier.update(user).deliver # sends the email
      redirect_to admin_users_path, :notice => 'You updated the user.'
    end
    
  end
  
end