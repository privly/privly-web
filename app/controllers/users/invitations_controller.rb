class Users::InvitationsController < Devise::InvitationsController
  
  before_filter :authenticate_user!, :only => [:index, :send_invitation, :send_update]
  before_filter :require_admin, :only => [:index, :send_invitation, :send_update]
  
  # POST /user/invitation
  def create
    
    self.resource = resource_class.invite!(params[resource_name], current_inviter) do |u|
      u.skip_invitation = false
      u.pending_invitation = false
    end

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions, :email => self.resource.email
      respond_with resource, :location => after_invite_path_for(resource)
    else
      respond_with_navigational(resource) { render :new }
    end
  end
  
  def index
    @requested_invites = User.where(:pending_invitation => true).page(params[:page]).order('created_at DESC')
    build_resource
  end
  
  def send_invitation
    
    user = User.find_by_id(params[:user][:id])
    
    if not user.pending_invitation or not user.confirmation_sent_at.nil?
      redirect_to user_invitations_path, :notice => 'That user is already pending an account.'
    else
      user.pending_invitation = false
      user.save
      user.invite!
      redirect_to user_invitations_path, :notice => 'Invitation was sent.'
    end
    
  end
  
  def send_update
    
    user = User.find_by_id(params[:user][:id])
    
    if not user.pending_invitation or not user.confirmation_sent_at.nil?
      redirect_to user_invitations_path, :notice => 'That user is already pending an account.'
    else
      Notifier.update(user).deliver # sends the email
      redirect_to user_invitations_path, :notice => 'You updated the user.'
    end
    
  end
  
end