ActiveAdmin.register User do
  
  # How many records to show per page
  config.per_page = 30
  
  # Allows for mass assignment of additional attributes
  controller do
    with_role :admin
  end
  
  # List of filters displayed to the right of the table
  filter :email
  filter :sign_in_count
  filter :current_sign_in_at
  filter :last_sign_in_at
  filter :confirmed_at
  filter :confirmation_sent_at
  filter :failed_attempts
  filter :created_at
  filter :alpha_invites
  filter :beta_invites
  filter :permissioned_requests_served
  filter :nonpermissioned_requests_served
  filter :can_post, :as => :select
  filter :notifications, :as => :select
  filter :wants_to_test
  filter :platform
  filter :last_emailed
  
  
  # Which columns are shown in the table
  index do
    selectable_column
    column :email
    column :sign_in_count
    column :last_sign_in_at
    column :created_at
    column :failed_attempts
    column :last_emailed
    #column :notifications
    
    column "Has Invites" do |user|
     user.alpha_invites > 0 or user.beta_invites > 0
    end
    
    column "Posts" do |user|
      user.posts.count
    end
    
    # Show, edit, delete
    actions
    
    column "Invite Status" do |user|
      if user.can_post
        "can post"
      elsif not user.pending_invitation and not user.invitation_accepted_at
        # invitation sent but not accepted
        link_to "Resend Invite", { :action => "send_invitation", 
          :controller=>"users/invitations", :user => {:id => user.id} },
          :confirm => "Send Invitation: Are you sure?", :method => :post
      elsif user.pending_invitation
        # invitation not sent
        link_to "Send Invite", { :action => "send_invitation", 
          :controller=>"users/invitations", :user => {:id => user.id} },
          :confirm => "Send Invitation: Are you sure?", :method => :post
      elsif not user.pending_invitation and user.invitation_accepted_at and not user.can_post
        # invitation sent, accepted, but can't post. This usually means the
        # user account was being abused somehow.
        "Deactivated Account"
      else
        raise "error, user account in unknown state"
      end
    end
  end
  
  # Turn on and off the user's posting ability
  #
  # This is an action you can perform on groups of users.
  # batch_action essentially registers a controller method, 
  # which is called by an automatically generated link on the index view
  # https://github.com/gregbell/active_admin/blob/master/docs/9-batch-actions.md#support-for-other-index-types
  batch_action :toggle_posting, :confirm => "Are you sure you want to toggle their posting permission?" do |selection|
    User.find(selection).each do |user|
      user.can_post = (user.can_post ^ true)
      user.save
    end
    redirect_to collection_path, :alert => "Users Have Been Toggled"
  end
  
  # Send an update email regarding the system
  batch_action :update_user_via_email, :confirm => "Are you sure you want to send them the update email?" do |selection|
    User.find(selection).each do |user|
      if user.can_post
        Notifier.update_invited_user(user).deliver_now
      end
    end
    redirect_to collection_path, :alert => "Users Have Been Updated via email"
  end
  
  # Importing CSV form calls collection_action :import_csv
  sidebar :import_csv do
    ul do
      li "Creat and update user perks"
      li "Format: email, alpha_invites, beta_invites, forever_account_value, tester, platform"
    end
    form_tag(import_csv_admin_users_path, :multipart => true) do
      file_field_tag('csv') +
      submit_tag("Submit", :confirm => "Are you sure you want to modify the user database with a CSV?")
    end
  end
  
  # Updates user table with the perks the user has. This should only be
  # applied once, or else it will restore the user account to full perks.
  # Users not in the table will be created, but they will not be emailed
  # an invitation or confirmation link.
  #
  # User accounts are confirmed on creation, but are not active without 
  # receiving an invitation or confirmation link. This means an
  # administrator or an already invited user needs to send an invitation link.
  # Users must recieve their invitation link in order to activate the content,
  # since there is still a sharing system underneath the content server that
  # can optionally authorize users based on emails.
  #
  # The CSV file is expected to have no header, but contain the following fields:
  # email,    alpha_invites,beta_invites,forever_account_value,tester,platform
  # Ex: 
  # e@dom.com,      1      ,      1     ,       100           ,  1   , firefox
  #
  # Named Route:
  # import_csv_admin_users_path
  collection_action :import_csv, :method => :post do
    
    require 'csv'
    
    total_imported = 0
    total_updated = 0
    
    CSV.parse(params[:csv].tempfile).each do |row|
      
      # Assign values from CSV
      email = row[0]
      alpha_invites = row[1]
      beta_invites = row[2]
      forever_account_value = row[3]
      wants_to_test = (row[4].to_i == 1)
      platform = row[5]
      
      # Update the user account if it exists,
      # else create the account.
      user = User.find_by_email(email.downcase)
      if user
        total_updated += 1
        unless user.can_post
          user.pending_invitation = true
        end
      else
        user = User.new
        user.email = email
        user.can_post = false
        user.pending_invitation = true
        user.password = SecureRandom.base64(12)
        user.platform = platform unless platform.nil?
        total_imported += 1
      end
      
      user.alpha_invites = alpha_invites unless alpha_invites.nil?
      user.beta_invites = beta_invites unless beta_invites.nil?
      user.forever_account_value = forever_account_value unless forever_account_value.nil?
      user.wants_to_test = wants_to_test unless wants_to_test.nil?
      
      # Don't email them the confirmation. This will result in the user account
      # being "confirmed," but they will not have the activation link without
      # an invite.
      user.skip_confirmation!
      
      if not user.save
        raise "error, new user in CSV would not save"
      end
      
    end
    
    redirect_to admin_users_path, :alert => "CSV Import Successfull, " + 
      "#{total_imported} imported, #{total_updated} updated"
  end
  
  ## Adds a button to the top of the page 
  # action_item :only => :index do
  #  link_to('This is an Action Item',root_path) 
  # end
  
end
